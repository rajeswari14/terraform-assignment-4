provider "aws" {
  region = "us-east-1"
}

locals {
  tags = merge(var.common_tags, {
    Environment = "dev"
    Project     = "terraform-assignment"
  })
}

module "vpc" {
  source              = "../../modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  vpc_name            = "task5-vpc"
  az                  = "us-east-1a"
}

module "ec2" {
  source        = "../../modules/ec2"
  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t3.micro"
  subnet_id     = module.vpc.public_subnet_id
  vpc_id        = module.vpc.vpc_id
  key_name      = var.key_name
  user_data     = file("${path.module}/user_data.sh")
}

module "ebs" {
  source            = "../../modules/ebs"
  availability_zone = module.ec2.availability_zone
  instance_id       = module.ec2.instance_id

  volume_size = var.data_volume_size
  volume_type = "gp3"
  device_name = "/dev/sdf"

  tags = local.tags
}

module "app_bucket" {
  source        = "../../modules/s3"
  bucket_name   = var.app_bucket_name
  force_destroy = true
  tags          = local.tags
}
