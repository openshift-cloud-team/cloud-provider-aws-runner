variable "AWS_REGION" {
  type = string
  description = "AWS region to deploy ec2 instance and configure cluster, also your environment AWS_REGION prefixed with TF_VAR_AWS_REGION"
}

variable "public_key" {
  type = string
  description = "Public ssh key to grant access to the instance"
}

variable "private_key" {
  type = string
  description = "Private ssh key to grant access to the instance"
}

variable "cluster" {
  type = string
  description = "Name of the kubernetes cluster, to tag the instance with"
}

variable "cluster_cidr" {
  type = string
  description = "cluster_cidr to use for VPC"
}

variable "public_cidr" {
  type = string
  description = "public_cidr to use for public subnet"
}

variable "private_cidr" {
  type = string
  description = "private_cidr to use for private subnet"
}

variable "AWS_PROFILE" {
  type = string
  description = "Your environment AWS_PROFILE prefixed with TF_VAR_AWS_PROFILE"
}

variable "AWS_ACCESS_KEY_ID" {
  type = string
  description = "Your environment AWS_ACCESS_KEY_ID prefixed with TF_VAR_AWS_ACCESS_KEY_ID"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type = string
  description = "Your environment AWS_SECRET_ACCESS_KEY prefixed with TF_VAR_AWS_SECRET_ACCESS_KEY"
}
