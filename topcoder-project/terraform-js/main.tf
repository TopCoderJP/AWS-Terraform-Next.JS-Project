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

# Policy in JSON format (grants public read access to all objects in the bucket)
    policy = jsonencode({
        "Version" = "2012-10-17",
        "Statement" = [
            {
                "Sid" = "PublicReadGetObject",
                "Effect" = "Allow",
                "Principal" = "*",
                "Action" = "s3:GetObject",
                "Resource" = "${aws_s3_bucket.nextjs_bucket.arn}/*"   # Applies to all objects in the bucket
            }
        ]
    })
}