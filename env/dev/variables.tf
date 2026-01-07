variable "key_name" {}
variable "data_volume_size" {
  type    = number
  default = 10
}

variable "app_bucket_name" {
  type = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}
