variable "cluster_id" {
  description = "The ECS cluster ID"
  default = "kibana_cluster"
}

variable "target_group" {
  description = "The ARN of the services target group"
}
