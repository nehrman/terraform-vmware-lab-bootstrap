resource "vsphere_host_port_group" "external" {
  count               = length(var.esxi_hosts)
  name                = "EXTERNAL"
  host_system_id      = data.vsphere_host.hosts[count.index].id
  virtual_switch_name = "vSwitch0"
}

resource "vsphere_host_virtual_switch" "internal" {
  count            = length(var.esxi_hosts)
  name             = "vSwitch1"
  host_system_id   = data.vsphere_host.hosts[count.index].id
  network_adapters = ["vmnic1"]
  active_nics      = ["vmnic1"]
  standby_nics     = []
}

resource "vsphere_host_port_group" "internal" {
  count               = length(var.esxi_hosts)
  name                = "INTERNAL"
  host_system_id      = data.vsphere_host.hosts[count.index].id
  virtual_switch_name = vsphere_host_virtual_switch.internal[count.index].name
}



resource "null_resource" "prep_content_library" {
  depends_on = [aws_s3_bucket_object.content_library]

  triggers = {
    objects = length(local.objects)
  }

  provisioner "local-exec" {
    command = "python3 ${path.module}/scripts/make_vcsp_2018.py -n hashi_library -t s3 -p vmware-lab-bucket/ContentLib"
  }
}

resource "vsphere_content_library" "new" {
  depends_on = [null_resource.prep_content_library, aws_s3_bucket_policy.content_library]
  name       = "hashi_library"
  subscription {
    subscription_url      = "http://vmware-lab-bucket.s3.eu-west-1.amazonaws.com/ContentLib/lib.json"
    authentication_method = "NONE"
    on_demand             = false
    automatic_sync        = true
  }
  storage_backing = [data.vsphere_datastore.datastore.id]
}

resource "vsphere_virtual_machine" "vyos" {
  name             = "router01"
#  datacenter_id    = data.vsphere_datacenter.dc.id
  host_system_id   = data.vsphere_host.hosts[0].id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  network_interface {
    network_id = data.vsphere_network.external.id
    ovf_mapping = "WAN"
  }

  network_interface {
    network_id = data.vsphere_network.internal.id
    ovf_mapping = "LAN"
  }


  disk {
    label            = "disk0"
    size             = 20
    thin_provisioned = true
  }
  /* ovf_deploy {
    remote_ovf_url= "https://vmware-lab-bucket.s3-eu-west-1.amazonaws.com/ContentLib/Vyos/vyos_vmware_image.ovf"
    disk_provisioning    = "thin"
    ip_protocol          = "IPV4"
    ip_allocation_policy = "STATIC_MANUAL"
    ovf_network_map = {
      "WAN" = data.vsphere_network.external.id
      "LAN" = data.vsphere_network.internal.id
    }
  }*/

  clone {
    template_uuid = data.vsphere_content_library_item.vyos.id
  }

  vapp {
    properties = {
      "password"       = "mypassword"
      "local-hostname" = "router01"
      "user-data"      = base64encode(file("${path.module}/files/user-data.yaml"))
    }
  }
}