resource "aws_lb_target_group" "ecs-application-lb-tg" {
  name     = "${var.application_name}-lb-tg"
  port     = "${var.application_port}"
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    path = "${var.health_check_path}"
    port = "${var.health_check_port}"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200"  # has to be HTTP 200 or fails
  }
}

resource "aws_lb" "ecs-application-lb" {
  name               = "${var.application_name}-lb"
  internal           = "${var.is_internal}"
  load_balancer_type = "application"
  security_groups    = ["${var.ecs_sg_id}"]
  subnets            = ["${var.subnet_ids}"]

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
