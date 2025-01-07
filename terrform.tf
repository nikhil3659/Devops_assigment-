terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
    region = "ap-south-1"
    access_key = var.Myaccess_Id
    secret_key = var.Mysecrate_key
}

resource "aws_s3_bucket" "bucket" {
  bucket = "my-web-bucket697835"
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
  content_disposition = "inline"
}

resource "aws_s3_object" "css_object" {
  bucket = aws_s3_bucket.bucket.id
  key    = "styles.css"
  source = "styles.css"
  content_type = "text/html"
  content_disposition = "inline"
}



resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.bucket.id
  depends_on = [ aws_s3_bucket_public_access_block.public_access ]
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
  depends_on = [ aws_s3_bucket_ownership_controls.ownership ]
}

output "endpoint" {
  value = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}