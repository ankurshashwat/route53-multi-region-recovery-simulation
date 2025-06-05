variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "route-53-multi-region-simulation-tf-state"
}

variable "table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "route-53-multi-region-simulation-tf-lock"
}

variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "route-53-multi-region-simulation"
}

variable "iam_user_arn" {
  description = "IAM user ARN for bucket access"
  type        = string
}