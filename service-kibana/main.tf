resource "aws_cloudwatch_log_group" "kibana" {
  name              = "kibana"
  retention_in_days = 3
}

resource "aws_ecs_task_definition" "kibana" {
  family = "kibana"
  container_definitions = "${file("service-kibana/service.json")}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:application =~ kibana"
  }
}

resource "aws_ecs_service" "kibana" {
  name            = "kibana"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.kibana.arn}"

  desired_count = 3
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 66
}
