provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_version = ">= 0.11.7"
}

locals {
  name        = "elk-cluster"
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

data "aws_subnet" "ecs_subnet_2A" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "10.10.200.0/28"
  tags = {
    Name = "ELK_Stack_2A"
  }
}

data "aws_subnet" "ecs_subnet_2B" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "10.10.210.0/28"
  tags = {
    Name = "ELK_Stack_2B"
  }
}

data "aws_subnet" "ecs_subnet_2C" {
  vpc_id     = "${var.vpc_id}"
  cidr_block = "10.10.220.0/28"
  tags = {
    Name = "ELK_Stack_2C"
  }
}

data "aws_security_group" "ecs_sg" {
  vpc_id = "${var.vpc_id}"
  name   = "${var.ecs_sg}"
  tags = {
    Name   = "ECS_Cluster"
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

#----- Load Balancers --------

module "logstash-lb" {
  source           = "./ecs-load-balancer"
  vpc_id           = "${var.vpc_id}"
  subnet_ids       = "${data.aws_subnet_ids.ecs_subnets.ids}"
  ecs_sg_id        = "${data.aws_security_group.ecs_sg.id}"
  application_name = "logstash"
  application_port = 5044
  lb_port          = 5044
  is_internal      = false
  health_check_path = "/?pretty"
  health_check_port = 9600
}

module "kibana-lb" {
  source           = "./ecs-load-balancer"
  vpc_id           = "${var.vpc_id}"
  subnet_ids       = "${data.aws_subnet_ids.ecs_subnets.ids}"
  ecs_sg_id        = "${data.aws_security_group.ecs_sg.id}"
  application_name = "kibana"
  application_port = 5601
  lb_port          = 80
  is_internal      = false
  health_check_path = "/app/kibana"
  health_check_port = 5601
}

resource "aws_lb_target_group_attachment" "lb-attach-logstash-2a" {
  target_group_arn = "${module.logstash-lb.target_group_arn}"
  target_id        = "${aws_instance.ecs-cluster-logstash-2a.id}"
  port             = "${var.logstash_port}"
}

resource "aws_lb_target_group_attachment" "lb-attach-logstash-2b" {
  target_group_arn = "${module.logstash-lb.target_group_arn}"
  target_id        = "${aws_instance.ecs-cluster-logstash-2b.id}"
  port             = "${var.logstash_port}"
}

resource "aws_lb_target_group_attachment" "lb-attach-logstash-2c" {
  target_group_arn = "${module.logstash-lb.target_group_arn}"
  target_id        = "${aws_instance.ecs-cluster-logstash-2c.id}"
  port             = "${var.logstash_port}"
}

resource "aws_lb_target_group_attachment" "lb-attach-kibana-2a" {
  target_group_arn = "${module.kibana-lb.target_group_arn}"
  target_id        = "${aws_instance.ecs-cluster-kibana-2a.id}"
  port             = "${var.kibana_port}"
}

resource "aws_lb_target_group_attachment" "lb-attach-kibana-2b" {
  target_group_arn = "${module.kibana-lb.target_group_arn}"
  target_id        = "${aws_instance.ecs-cluster-kibana-2b.id}"
  port             = "${var.kibana_port}"
}

resource "aws_lb_target_group_attachment" "lb-attach-kibana-2c" {
  target_group_arn = "${module.kibana-lb.target_group_arn}"
  target_id        = "${aws_instance.ecs-cluster-kibana-2c.id}"
  port             = "${var.kibana_port}"
}

#----- ECS  Services--------

module "elasticsearch" {
  source     = "./service-elasticsearch"
  cluster_id = "${element(concat(aws_ecs_cluster.cluster.*.id, list("")), 0)}"
}

module "kibana" {
  source       = "./service-kibana"
  cluster_id   = "${element(concat(aws_ecs_cluster.cluster.*.id, list("")), 0)}"
}

module "logstash" {
  source     = "./service-logstash"
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
  ami                    = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id              = "${data.aws_subnet.ecs_subnet_2A.id}"
  private_ip             = "10.10.200.4"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-elasticsearch.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "elasticsearch-2a"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-elasticsearch-2b" {
  ami                    = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id              = "${data.aws_subnet.ecs_subnet_2B.id}"
  private_ip             = "10.10.210.4"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-elasticsearch.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "elasticsearch-2b"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-elasticsearch-2c" {
  ami                    = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id              = "${data.aws_subnet.ecs_subnet_2C.id}"
  private_ip             = "10.10.220.4"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-elasticsearch.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "elasticsearch-2c"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-kibana-2a" {
  ami                  = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id            = "${data.aws_subnet.ecs_subnet_2A.id}"
  private_ip             = "10.10.200.5"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-kibana.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "kibana-2a"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-kibana-2b" {
  ami                    = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id              = "${data.aws_subnet.ecs_subnet_2B.id}"
  private_ip             = "10.10.210.5"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-kibana.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "kibana-2b"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-kibana-2c" {
  ami                    = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id              = "${data.aws_subnet.ecs_subnet_2C.id}"
  private_ip             = "10.10.220.5"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-kibana.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "kibana-2c"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-logstash-2a" {
  ami                  = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id            = "${data.aws_subnet.ecs_subnet_2A.id}"
  private_ip             = "10.10.200.6"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-logstash.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "logstash-2a"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-logstash-2b" {
  ami                    = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id              = "${data.aws_subnet.ecs_subnet_2B.id}"
  private_ip             = "10.10.210.6"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-logstash.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "logstash-2b"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}

resource "aws_instance" "ecs-cluster-logstash-2c" {
  ami                    = "${data.aws_ami.amazon_linux_ecs.id}"
  subnet_id              = "${data.aws_subnet.ecs_subnet_2C.id}"
  private_ip             = "10.10.220.6"
  instance_type          = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.ecs_sg.id}"]
  iam_instance_profile   = "${module.ecs-instance-policy.iam_instance_profile_id}"
  user_data              = "${file("${path.module}/user-data-logstash.sh")}"
  key_name               = "${var.key_name}"

  tags = {
    Name          = "logstash-2c"
    Environment   = "${local.environment}"
    Cluster       = "${local.name}"
  }
}
