data "aws_caller_identity" "current" {}

data "vsphere_resource_pool" "pool" {
  name          = "VSANCLUSTER01/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "hosts" {
  count         = length(var.esxi_hosts)
  name          = var.esxi_hosts[count.index]
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datacenter" "dc" {
  name = "MYVWORLD"
}

data "vsphere_datastore" "datastore" {
  name          = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_content_library_item" "vyos" {
  depends_on = [vsphere_content_library.new, null_resource.wait]
  name       = "Vyos"
  library_id = vsphere_content_library.new.id
  type       = "OVF"
}

data "vsphere_network" "external" {
  depends_on    = [vsphere_host_port_group.external]
  name          = "EXTERNAL"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "internal" {
  depends_on    = [vsphere_host_port_group.internal]  
  name          = "INTERNAL"
  datacenter_id = data.vsphere_datacenter.dc.id
}