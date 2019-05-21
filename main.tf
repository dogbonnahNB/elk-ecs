provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_version = ">= 0.11.7"
}

locals {
  name        = "fast-ecs"
  environment = "dev"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}


data "aws_vpc" "ecs_vpc" {
  id = "${var.vpc_id}"
}

data "aws_subnet_ids" "ecs_subnets" {
  vpc_id = "${var.vpc_id}"
}

data "aws_security_group" "selected" {
  vpc_id = "${data.aws_vpc.ecs_vpc.id}"
  tags {
    Name = "ECS_Cluster"
  }
}

#----- ECS --------

resource "aws_ecs_cluster" "cluster" {
  count = "${var.create_ecs ? 1 : 0}"

  name = "${var.cluster_name}"
  tags = "${var.cluster_tags}"
}


resource "aws_iam_role" "iam_role" {
  name = "${var.policy_name}_ecs_instance_role"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.policy_name}_ecs_instance_profile"
  role = "${aws_iam_role.iam_role.name}"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role       = "${aws_iam_role.iam_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role       = "${aws_iam_role.iam_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

#----- ECS  Services--------

module "elasticsearch" {
  source     = "./service-elasticsearch"
  cluster_id = "${element(concat(aws_ecs_cluster.cluster.*.id, list("")), 0)}"
}

#----- ECS  Resources--------

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "aws_launch_configuration" {
  source = "terraform-aws-modules/autoscaling/aws"

  name = "${local.ec2_resources_name}"

  # Launch configuration
  lc_name = "${local.ec2_resources_name}"

  image_id             = "${data.aws_ami.amazon_linux_ecs.id}"
  instance_type        = "${var.instance_type}"
  security_groups      = ["${data.aws_security_group.selected.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.id}"
  user_data            = "${file("${path.module}/user-data.sh")}"

  # Auto scaling group
  asg_name                  = "${local.ec2_resources_name}"
  vpc_zone_identifier       = "${data.aws_subnet_ids.ecs_subnets.ids}"
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 4
  desired_capacity          = 2
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
