provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_version = ">= 0.11.7"
}

locals {
  name        = "ecs-cluster"
  environment = "production"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}


data "aws_vpc" "ecs_vpc" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "ecs_subnets" {
  vpc_id = "${var.vpc_id}"
}

data "aws_subnet_ids" "ecs_subnet_2A" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "ELK_Stack_2A"
  }
}

data "aws_subnet_ids" "ecs_subnet_2B" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "ELK_Stack_2B"
  }
}

data "aws_subnet_ids" "ecs_subnet_2C" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "ELK_Stack_2C"
  }
}

data "aws_vpc_security_group_ids" "selected" {
  tags = {
    Name   = "ECS_Cluster"
  }

  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.ecs_vpc.id}"]
  }
}

#----- ECS --------

resource "aws_ecs_cluster" "cluster" {
  count = "${var.create_ecs ? 1 : 0}"

  name = "${var.cluster_name}"
  tags = "${var.cluster_tags}"
}

module "ecs-instance-policy" {
  source      = "./ecs-instance-policy"
  policy_name = "${var.policy_name}"
}

#----- ECS  Services--------

module "elasticsearch" {
  source     = "./service-elasticsearch"
  cluster_id = "${element(concat(aws_ecs_cluster.cluster.*.id, list("")), 0)}"
}

#----- ECS  Resources--------

data "aws_ami" "amazon_linux_ecs" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_instance" "ecs-cluster-elasticsearch-2a" {
  ami                  = "${data.aws_ami.amazon_linux_ecs.id}"
  private_ip           = "10.10.200.4"
  instance_type        = "${var.instance_type}"
  vpc_security_group_ids      = "${data.aws_vpc_security_group_ids.selected.ids}"
  iam_instance_profile = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data            = "${file("${path.module}/user-data.sh")}"
  key_name             = "${var.key_name}"

  tags = {
    Name          = "elasticsearch-2a"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-elasticsearch-2b" {
  ami                  = "${data.aws_ami.amazon_linux_ecs.id}"
  private_ip           = "10.10.210.4"
  instance_type        = "${var.instance_type}"
  vpc_security_group_ids      = "${data.aws_vpc_security_group_ids.selected.ids}"
  iam_instance_profile = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data            = "${file("${path.module}/user-data.sh")}"
  key_name             = "${var.key_name}"

  tags = {
    Name          = "elasticsearch-2b"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-elasticsearch-2c" {
  ami                  = "${data.aws_ami.amazon_linux_ecs.id}"
  private_ip           = "10.10.220.4"
  instance_type        = "${var.instance_type}"
  vpc_security_group_ids      = "${data.aws_vpc_security_group_ids.selected.ids}"
  iam_instance_profile = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data            = "${file("${path.module}/user-data.sh")}"
  key_name             = "${var.key_name}"

  tags = {
    Name          = "elasticsearch-2c"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}
