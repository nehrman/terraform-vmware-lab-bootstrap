variable "bucket_name" {
  description = "Defines the S3 Bucket Name"
  default     = "vmware-lab-bucket"
}

variable "esxi_hosts" {
  description = "List ESXi Hosts"
  type        = list(any)
  default = [
    "esx01.my-v-world.fr",
    "esx02.my-v-world.fr",
    "esx03.my-v-world.fr"
  ]
}