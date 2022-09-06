variable "price_class" {
  type        = string
  description = "Cloud Front Price Class"
}

variable "origin-id" {
  type        = string
  description = "Unique Origin ID"
}

variable "origin-id-comment" {
  type        = string
  description = "Origin ID comment"
}

variable "distribution-comment" {
  type        = string
  description = "Cloud Front distribution comment"
}

variable "bucket_name" {
  type        = string
  description = "S3 Bucket domain name"
}


variable "lambda_file" {
  type        = string
  description = "Lambda file location"
}

variable "lambda_function_name" {
  type        = string
  description = "Lambda function name"
}


variable "pip_package" {
  type        = string
  description = "lambda layer arn"
}