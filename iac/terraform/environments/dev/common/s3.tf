resource "aws_s3_bucket" "this" {
  count = var.cloudfront_created ? 1 : 0
  bucket = "${local.name_prefix}-static-bucket"
  tags   = local.common_tags
}

# resource "aws_s3_bucket_acl" "this" {
#   count = var.cloudfront_created ? 1 : 0
#   bucket = aws_s3_bucket.this[0].id
#   acl    = "private"
# }

resource "aws_cloudfront_origin_access_identity" "this" {
  count = var.cloudfront_created ? 1 : 0
  comment = "cloudfront-site-access-identity"
}

resource "aws_s3_bucket_policy" "this" {
  count = var.cloudfront_created ? 1 : 0
  bucket = aws_s3_bucket.this[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = {
          "AWS" : aws_cloudfront_origin_access_identity.this[0].iam_arn,
        }
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.this[0].arn}",
          "${aws_s3_bucket.this[0].arn}/static",
          "${aws_s3_bucket.this[0].arn}/static/*",
        ]
      },
    ]
  })
}
resource "aws_s3_bucket_public_access_block" "this" {

  count = var.cloudfront_created ? 1 : 0  
  bucket = aws_s3_bucket.this[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_distribution" "this" {

  count = var.cloudfront_created ? 1 : 0

  origin {
    domain_name = aws_s3_bucket.this[0].bucket_regional_domain_name
    origin_id   = aws_s3_bucket.this[0].id
    origin_path = ""
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path
    }
  }

  enabled             = var.cloudfront_created
  is_ipv6_enabled     = true
  comment             = "${local.name_prefix}-static"
  default_root_object = "index.html"
  # aliases             = var.aliases
  viewer_certificate {
    cloudfront_default_certificate = true
    # Using when using custom domain.
    # cloudfront_default_certificate  = false
    # acm_certificate_arn             = var.acm_certificate_arn
    # ssl_support_method = "sni-only"
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.this[0].id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 900
    max_ttl                = 3600
  }

  custom_error_response {
    error_caching_min_ttl = 60
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }
  custom_error_response {
    error_caching_min_ttl = 60
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.common_tags



}

