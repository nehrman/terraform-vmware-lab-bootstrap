locals {
  objects = csvdecode(file("${path.module}/files/objects.csv"))
}

resource "aws_s3_bucket" "content_library" {
  bucket        = var.bucket_name
  force_destroy = "true"
  tags          = { "hc-internet-facing" : "true" }
}

resource "aws_s3_bucket_policy" "content_library" {
  bucket = aws_s3_bucket.content_library.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "vmware-lab-bucket",
  "Statement": [
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::vmware-lab-bucket/*"
    }
  ]
}
POLICY
}


resource "aws_s3_bucket_object" "content_library" {
  for_each = { for object in local.objects : object.source => object }
  bucket   = aws_s3_bucket.content_library.id
  source   = each.value.source
  key      = each.value.key
}

