terraform {
  backend "s3" {
    bucket         = "my-terraform-task5-state"   # your S3 bucket
    key            = "env/prod/terraform.tfstate"  # path to state file
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"            # your DynamoDB table
    encrypt        = true
  }
}
