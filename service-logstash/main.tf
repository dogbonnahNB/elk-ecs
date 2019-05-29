resource "aws_cloudwatch_log_group" "logstash" {
  name              = "logstash"
  retention_in_days = 3
}

resource "aws_ecs_task_definition" "logstash" {
  family = "logstash"
  container_definitions = "${file("service-logstash/service.json")}"

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:application =~ logstash"
  }
}

resource "aws_ecs_service" "logstash" {
  name            = "logstash"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.logstash.arn}"

  desired_count = 3

  load_balancer {
    target_group_arn = "${var.target_group}"
    container_name   = "logstash"
    container_port   = "5044"
  }

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 66
}
