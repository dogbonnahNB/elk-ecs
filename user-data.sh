#!/bin/bash
# Set the ECS agent configuration options

#Host config
sysctl -w vm.max_map_count=262144

# ECS config

echo "ECS_CLUSTER=fast-cluster" >> /etc/ecs/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=15m" >> /etc/ecs/ecs.config
echo "ECS_IMAGE_CLEANUP_INTERVAL=10m" >> /etc/ecs/ecs.config

start ecs

echo "Done"
