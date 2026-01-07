output "public_ip" {
  value = module.ec2.public_ip
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "app_bucket_name" {
  value = module.app_bucket.bucket_name
}

output "ebs_volume_id" {
  value = module.ebs.volume_id
}
