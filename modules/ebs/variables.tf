variable "availability_zone" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type    = string
  default = "gp3"
}

variable "device_name" {
  type    = string
  default = "/dev/sdf"
}

variable "tags" {
  type    = map(string)
  default = {}
}
