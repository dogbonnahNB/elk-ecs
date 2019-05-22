#!/bin/bash

#Host config
sysctl -w vm.max_map_count=262144

# ECS config
{
  echo "ECS_CLUSTER=fast-cluster"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
