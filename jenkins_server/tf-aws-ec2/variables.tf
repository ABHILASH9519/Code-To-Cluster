variable "aws_region" {
    description = "The region where the infrastructure should be deployed to"
    type = string
}

variable "aws_account_id" {
    description = "AWS Account ID"
    type = string
}

variable "backend_jenkins_bucket" {
    description = "S3 bucket where jenkins terraform state file will be stored"
    type = string
}

variable "backend_jenkins_bucket_key" {
    description = "bucket key for the jenkins terraform state file"
    type = string
}

variable "vpc_name" {
  description = "VPC Name for Jenkins Server VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR for Jenkins Server VPC"
  type        = string
}

variable "public_subnets" {
  description = "Subnets CIDR range"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "jenkins_security_group" {
  description = "Instance Type"
  type        = string
}

variable "jenkins_ec2_instance" {
  description = "Instance Type"
  type        = string
}
variable "admin_cidrs" {
  description = "Trusted IPv4 CIDR ranges allowed to reach Jenkins, SSH and SonarQube. Empty by default."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.admin_cidrs : can(cidrnetmask(cidr))])
    error_message = "Every admin_cidrs entry must be a valid IPv4 CIDR range."
  }
}
