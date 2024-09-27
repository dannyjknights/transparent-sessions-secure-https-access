variable "boundary_addr" {
  type = string
}

variable "password_auth_method_login_name" {
  type = string
}

variable "password_auth_method_password" {
  type = string
}

variable "aws_access" {
  type = string
}

variable "aws_secret" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "private_vpc_cidr" {
  type        = string
  description = "The Private CIDR range to assign to the VPC"
}

variable "aws_vpc_cidr" {
  type        = string
  description = "The AWS Region CIDR range to assign to the VPC"
}

variable "private_subnet_cidr" {
  type        = string
  description = "The Private CIDR range to assign to the Private subnet"
}

variable "aws_subnet_cidr" {
  type        = string
  description = "The AWS Region CIDR range to assign to the Private subnet"
}

variable "availability_zone" {
  type        = string
  description = "Region within AWS to deploy the resources"
  default     = "eu-west-2b"
}

variable "ni_tags" {
  type        = map(any)
  description = "Tag to identify the network interface on the resource"
  default = {
    Name = "boundary-vm-nic"
  }
}

variable "vault_addr" {
  type = string
}