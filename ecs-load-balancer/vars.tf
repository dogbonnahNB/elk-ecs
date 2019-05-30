variable "vpc_id" {
  description = "The ID of the selected precreated VPC"
}

variable "subnet_ids" {
  description = "The ID of the subnets to apply the load balancer to"
  type        = "list"
}

variable "ecs_sg_id" {
  description = "The name of the key to access autoscaling group instances"
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

variable "health_check_path" {
  description = "Path for health check"
}

variable "health_check_port" {
  description = "Port for health check"
}
