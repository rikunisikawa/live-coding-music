variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "data_lake" {
  bucket = var.bucket_name
}
