provider "vsphere" {
  user           = "administrator@vsphere.local"
  password       = "G9kEQ7=T]e|w^-[We"
  vsphere_server = "vcsa.my-v-world.fr"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}
