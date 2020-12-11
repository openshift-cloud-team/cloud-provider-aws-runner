variable "public_key" {
  description = "Public ssh key to grant access to the instance"
}

variable "private_key" {
  description = "Private ssh key to grant access to the instance"
}

variable "cluster" {
  description = "Name of the kubernetes cluster, to tag the instance with"
}

variable "cluster_cidr" {
  description = "cluster_cidr to use for VPC"
}

variable "public_cidr" {
  description = "public_cidr to use for public subnet"
}

variable "private_cidr" {
  description = "private_cidr to use for private subnet"
}

variable "ami" {
  description = "Your image AMI for the instance to run."
}

variable "instance_type" {
  description = "The instance size to run."
}

variable "AWS_REGION" {
  description = "AWS region to deploy ec2 instance and configure cluster, also your environment TF_VAR_AWS_REGION by default."
}

variable "AWS_PROFILE" {
  description = "Your environment TF_VAR_AWS_PROFILE by default."
}

variable "AWS_ACCESS_KEY_ID" {
  description = " Your environment TF_VAR_AWS_ACCESS_KEY_ID by default."
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "Your environment TF_VAR_AWS_SECRET_ACCESS_KEY"
}
