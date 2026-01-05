provider "aws" {
  region = "us-east-1"
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
