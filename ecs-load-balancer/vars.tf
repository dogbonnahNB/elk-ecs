variable "subnet_ids" {
  description = "The ID of the selected precreated VPC"
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
