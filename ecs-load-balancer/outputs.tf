output "target_group_arn" {
  value = "${aws_lb_target_group.ecs-application-lb-tg.arn}"
}
