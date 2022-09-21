variable "aws-region" {
  type        = string
  default     = "us-west-2" # TODO: UPDATE THIS WITH THE REGION YOU WANT TO USE OR OVERRIDE THE VALUE AS A PARAMETER TO THE TEMPLATE
  description = "the aws region to deploy resources into"

  validation {
    condition     = contains(["us-east-1", "us-east-2", "us-west-1", "us-west-2", "ca-central-1"], var.aws-region)
    error_message = "invalid region entered"
  }
}

variable "default-vpc" {
  type        = string
  default     = "<vpc-id>" # TODO: UPDATE THIS WITH AN ID FOR A DEFAULT VPC OR OVERRIDE THE VALUE AS A PARAMETER TO THE TEMPLATE
  description = "the id of the default vpc for the specified aws-region"

  validation {
    condition     = length(var.default-vpc) > 0
    error_message = "default-vpc is required"
  }
}