variable "create_ecs" {
  description = "Controls if ECS should be created"
  default     = true
}

variable "cluster_name" {
  description = "Name to be used on all the resources as identifier, also the name of the ECS cluster"
  default = "elk-cluster"
}

variable "cluster_tags" {
  description = "A map of tags to add to ECS Cluster"
  default     = {}
}

variable "instance_type" {
  description = "A map of tags to add to ECS Cluster"
  default     = "t2.medium"
}

variable "policy_name" {
  description = "Name to be used on all the resources as identifier"
  default = "ecs-instance-policy"
}

variable "vpc_id" {
  description = "The ID of the selected precreated VPC"
  default     = "vpc-0116e9499d2eadf31"
}

variable "key_name" {
  description = "The name of the key to access autoscaling group instances"
  default     = "accentKey"
}

variable "ecs_sg" {
  description = "The name of the key to access autoscaling group instances"
  default     = "ECS_Cluster"
}

variable "logstash_port" {
  description = "Port number logstash application is listening on instances"
  default     = 5044
}

variable "kibana_port" {
  description = "Port number logstash application is listening on instances"
  default     = 5601
}
