#!/bin/bash
# Set the ECS agent configuration options

#Host config
sysctl -w vm.max_map_count=262144
mkdir -p /usr/share/elasticsearch/data/
chown -R 1000.1000 /usr/share/elasticsearch/data/

# ECS config
{
  echo "ECS_CLUSTER=fast-cluster"
  echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=15m"
  echo "ECS_IMAGE_CLEANUP_INTERVAL=10m"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
