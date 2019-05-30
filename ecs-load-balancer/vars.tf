variable "vpc_id" {
  description = "The ID of the selected precreated VPC"
  default     = "vpc-0116e9499d2eadf31"
}

variable "ecs_sg" {
  description = "The name of the key to access autoscaling group instances"
  default     = "ECS_Cluster"
}

variable "application_name" {
  description = "The name of the appication"
}

variable "application_port" {
  description = "The the port on which the application is accepting connections"
}

variable "lb_port" {
  description = "The port the loadbalancer listens"
}

variable "is_internal" {
  description = "Whether or not the load balancer is internal"
}
