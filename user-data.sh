#!/bin/bash

# ECS config
{
  echo "ECS_CLUSTER=fast-cluster"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
