
terraform {
    backend "s3" {
        bucket = "topcoder-terraform-state"
        key = "global/s3/terraform.tfstate"
        region = "ap-northeast-1"
        dynamodb_table = "terraform-lock-file"
    }
}