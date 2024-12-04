terraform {
  backend "s3" {
    bucket = "my-terraformeks-state-bucket"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
} 