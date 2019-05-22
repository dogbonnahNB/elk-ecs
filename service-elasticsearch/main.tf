resource "aws_cloudwatch_log_group" "elasticsearch" {
  name              = "elasticsearch"
  retention_in_days = 3
}

resource "aws_ecs_task_definition" "elasticsearch" {
  family = "elasticsearch"
  container_definitions = "${file("service-elasticsearch/service.json")}"

  volume {
    name = "esdata"

    docker_volume_configuration {
      scope         = "shared"
      autoprovision = true
    }
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [eu-west-2a, eu-west-2b]"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.instance-type =~ t2.*"
  }
}

resource "aws_ecs_service" "elasticsearch" {
  name            = "elasticsearch"
  cluster         = "${var.cluster_id}"
  task_definition = "${aws_ecs_task_definition.elasticsearch.arn}"

  desired_count = 3

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 66
}
