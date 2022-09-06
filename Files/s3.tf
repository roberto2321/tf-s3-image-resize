
resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}

# resource "aws_s3_object" "images" {
#   bucket       = aws_s3_bucket.bucket.id
#   acl          = "private"
#   key          = "Images/"
#   content_type = "application/x-directory"
# }

# resource "aws_s3_object" "processed" {
#   bucket       = aws_s3_bucket.bucket.id
#   acl          = "private"
#   key          = "Processed_Images/"
#   content_type = "application/x-directory"
# }

resource "aws_s3_bucket_public_access_block" "public-block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}


resource "aws_s3_bucket_policy" "prod_website" {
  bucket = aws_s3_bucket.bucket.id
  depends_on = [
    aws_s3_bucket.bucket,
    aws_cloudfront_origin_access_identity.cf,
    aws_cloudfront_distribution.s3_distribution
  ]

  policy = <<POLICY
{    
    "Version": "2012-10-17",    
    "Statement": 
    [ 
        {
            "Sid": "cloud-front-read-access",
            "Effect": "Allow",
            "Principal": {
                "CanonicalUser": "${aws_cloudfront_origin_access_identity.cf.s3_canonical_user_id}"
                },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
        }
    ]
}
POLICY
}