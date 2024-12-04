terraform {
  backend "s3" {
    bucket         = var.s3_bucket
    key            = var.s3_key
    region         = var.aws_region
    dynamodb_table = var.dynamodb_table
  }
}
