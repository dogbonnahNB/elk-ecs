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

data "aws_security_groups" "selected" {
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

module "aws_launch_configuration" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${local.ec2_resources_name}"

  # Launch configuration
  lc_name = "${local.ec2_resources_name}"

  image_id             = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type        = "${var.instance_type}"
  security_groups      = "${data.aws_security_groups.selected.ids}"
  iam_instance_profile = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data            = "${file("${path.module}/user-data.sh")}"
  key_name             = "${var.key_name}"

  # Auto scaling group
  asg_name                  = "${local.ec2_resources_name}"
  vpc_zone_identifier       = ["${data.aws_subnet_ids.ecs_subnets.ids[0]}"]
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 3
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = "${local.environment}"
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = "${local.name}"
      propagate_at_launch = true
    },
  ]
}
