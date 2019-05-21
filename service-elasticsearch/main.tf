resource "aws_cloudwatch_log_group" "elasticsearch" {
  name              = "elasticsearch"
  retention_in_days = 3
}

resource "aws_ecs_task_definition" "elasticsearch" {
  family = "elasticsearch"
  container_definitions = "${file("service-elasticsearch/service.json")}"
}

resource "aws_ecs_service" "elasticsearch" {
  name            = "elasticsearch"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.elasticsearch.arn}"

  desired_count = 8

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 50
}
