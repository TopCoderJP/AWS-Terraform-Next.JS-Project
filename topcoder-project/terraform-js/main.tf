# Provider configuration
# Specifies that Terraform will use the AWS provider and deploy resources in the ap-northeast-1 region
provider "aws" {
    region = "ap-northeast-1"
}


# S3 Bucket definitions
# Creates an S3 bucket to store static content for the Next.js site
resource "aws_s3_bucket" "nextjs_bucket" {
    bucket = "topcoder-nextjs-bucket"
}

# Ownership control
# Ensures that the bucket owner has full control over the objects in the bucket
resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_controls" {
    bucket = aws_s3_bucket.nextjs_bucket.id

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}


# Public Access Block
# Disables public access blocking, allowing the bucket to be publicly accessible
resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
    bucket = aws_s3_bucket.nextjs_bucket.id

# disable block public access - can be publicly accessible
    block_public_acls = false        # Do not block public ACLs
    block_public_policy = false      # Do not block public bucket policies
    ignore_public_acls = false       # Do not ignore public ACLs
    restrict_public_buckets = false  # Do not restrict public buckets
}



# Multiple layers of security

# Bucket ACL (Access Control List)
# Sets the bucket's ACL to public-read, allowing public access to the bucket's objects
resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {
    depends_on = [
        aws_s3_bucket_ownership_controls.nextjs_bucket_ownership_controls,
        aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block
    ]
    bucket = aws_s3_bucket.nextjs_bucket.id
    acl = "public-read"             # Grants public read access to the bucket
}


# Bucket Policy
# Defines an explicit policy to allow public read access to the bucket's objects
resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
    bucket = aws_s3_bucket.nextjs_bucket.id
    depends_on = [
        aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block
    ]

    policy = jsonencode({
        "Version" = "2012-10-17",
        "Statement" = [
            {
                "Sid" = "PublicReadGetObject",
                "Effect" = "Allow",
                "Principal" = "*",
                "Action" = "s3:GetObject",
                "Resource" = "${aws_s3_bucket.nextjs_bucket.arn}/*"
            }
        ]
    })
}

# CloudFront Origin Access Identity (OAI)
# Creates an OAI to restrict direct access to the S3 bucket and allow only CloudFront to serve content
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
    comment = "OAI for NextJS site - Allows CloudFront to reach the bucket"
}


# CloudFront Distribution
# Creates a CloudFront distribution for the Next.js site with caching and HTTPS enabled
resource "aws_cloudfront_distribution" "nextjs_distribution" {

  # origin settings
  origin {
    # defines where to find bucket
    domain_name = aws_s3_bucket.nextjs_bucket.bucket_regional_domain_name # Specifies the S3 bucket as the origin
    origin_id   = "topcoder-nextjs-bucket" # Unique ID for the origin

    # Configures CloudFront to use the OAI for accessing the S3 bucket
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true # Enables the distribution
  is_ipv6_enabled     = true # Enables IPv6 support
  comment             = "Next.js portfolio site" # Descriptive comment
  default_root_object = "index.html" # Default file to serve when no specific file is requested

  # Cache behavior settings
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"] # Allowed HTTP methods
    cached_methods = ["GET", "HEAD"] # Methods cached by CloudFront
    target_origin_id = "topcoder-nextjs-bucket" # Links the behavior to the S3 origin
    viewer_protocol_policy = "redirect-to-https" # Redirects HTTP requests to HTTPS

     # Forwarded values (controls how query strings and cookies are forwarded)
    forwarded_values {
      query_string = false # Query strings are not forwarded
      cookies {
        forward = "none" # Cookies are not forwarded
      }
    }



    min_ttl     = 0      # Minimum time an object is cached
    default_ttl = 3600   # Default time to cache objects (1 hour)
    max_ttl     = 86400  # Maximum time an object is cached ( i.e content is refreshed at least once every 24 hours)
  }

  # ensures data is encrypted via Default Cloudfront shared TSL, SSL and HTTPS certificates 
  viewer_certificate {
    cloudfront_default_certificate = true # Uses default CloudFront HTTPS certificate

  }

  # Geographical restrictions
  restrictions {
    # Can restrict access to specific countries
    geo_restriction {
      restriction_type = "none" # No restrictions on countries
    }
  }


}
