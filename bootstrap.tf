
provider "aws" {
  profile = var.AWS_PROFILE
  region  = var.AWS_REGION
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "aws-local-up-access-key"
  public_key = file(var.public_key)
}

resource "aws_security_group" "default_group" {
  name        = "security-group"
  vpc_id = aws_vpc.cluster_vpc.id

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.cluster
  }
}

resource "aws_vpc" "cluster_vpc" {
  cidr_block = var.cluster_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster}"  = "owned"
    Name = var.cluster
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.cluster_vpc.id
  cidr_block = var.public_cidr

  tags = {
    "kubernetes.io/cluster/${var.cluster}"  = "owned"
    Name = "${var.cluster}-public"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.cluster_vpc.id
  cidr_block = var.private_cidr

  tags = {
    "kubernetes.io/cluster/${var.cluster}"  = "owned"
    Name = "${var.cluster}-private"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.cluster_vpc.id

  tags = {
    Name = var.cluster
  }
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "ec2_policy"
  role = aws_iam_role.ec2_role.id

  policy = file("cloud-local-up/master.json")
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = file("cloud-local-up/iam_role.json")
}

resource "aws_iam_instance_profile" "bootstrap_profile" {
  name = "bootstrap_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "node" {
  name        = "node"
  description = "Node IAM policy for cloud-provider"

  policy = file("cloud-local-up/node.json")
}

resource "aws_instance" "host" {
  key_name      = aws_key_pair.ssh_key.key_name
  ami           = "ami-07533cd77d753da7b"
  instance_type = "m5.large"
  subnet_id = aws_subnet.public.id
  iam_instance_profile = aws_iam_instance_profile.bootstrap_profile.id
  associate_public_ip_address = true
  user_data = format(file("cloud-local-up/user_data.sh"), var.AWS_ACCESS_KEY_ID, var.AWS_SECRET_ACCESS_KEY,  var.AWS_REGION, var.cluster_cidr, aws_iam_policy.node.arn)

  tags = {
    "kubernetes.io/cluster/${var.cluster}"  = "owned"
    Name = var.cluster
  }

  vpc_security_group_ids = [ aws_security_group.default_group.id ]

  depends_on = [ aws_vpc.cluster_vpc, aws_internet_gateway.gw ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key)
    host        = self.public_ip
  }

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = 30
  }
}

resource "aws_eip" "gw" {
  vpc      = true
  depends_on = [aws_internet_gateway.gw]

  tags = {
    Name = var.cluster
  }
}

resource "aws_nat_gateway" "gw" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.gw.id

  tags = {
    Name =  "${var.cluster}-NAT"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_vpc.cluster_vpc.main_route_table_id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_vpc.cluster_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

output "ssh_access" {
  value = aws_eip.gw.public_ip
  depends_on = [aws_eip.gw]
  description = "The public IP address of the EC2 instance. To connect use `$ ssh fedora@<output-ip-addr> -i <your_private_key>`"
}
