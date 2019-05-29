data "aws_security_group" "ecs_sg" {
  vpc_id = "${var.vpc_id}"
  name   = "${var.ecs_sg}"
}

data "aws_subnet_ids" "ecs_subnets" {
  vpc_id = "${var.vpc_id}"
}

resource "aws_lb_target_group" "ecs-application-lb-tg" {
  name     = "${var.application_name}-lb-tg"
  port     = "${var.application_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

resource "aws_lb" "ecs-application-lb" {
  name               = "${var.application_name}-lb"
  internal           = "${var.is_internal}"
  load_balancer_type = "application"
  security_groups    = ["${data.aws_security_group.ecs_sg.id}"]
  subnets            = ["${data.aws_subnet_ids.ecs_subnets.*.id}"]

  enable_deletion_protection = true
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_lb.ecs-application-lb.arn}"
  port              = "${var.lb_port}"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.ecs-application-lb-tg.arn}"
  }
}
