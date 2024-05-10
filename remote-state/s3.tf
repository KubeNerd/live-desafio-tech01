resource "aws_s3_bucket" "bucket" {
  bucket = "desafiotech01"
  tags = {
    "Terraform" = true
    "Environment" = "development"
    "Project" = "live-desafio-devops"
  }
}

resource "aws_s3_bucket_versioning" "versioning_bucket" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}