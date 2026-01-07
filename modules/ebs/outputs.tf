output "volume_id" {
  value = aws_ebs_volume.this.id
}

output "device_name" {
  value = var.device_name
}
