provider "vsphere" {
  user           = var.vc_username
  password       = var.vc_password
  vsphere_server = var.vc.server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
