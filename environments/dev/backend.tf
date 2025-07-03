terraform {
  backend "s3" {
    bucket         = "my-eks-prod-tfstate" # replace with your bucket
    key            = "dev/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "my-eks-prod-tf-lock" # replace with your table
    encrypt        = true
  }
}