#!/bin/bash
# Set the ECS agent configuration options

# ECS config

echo "ECS_CLUSTER=elk-cluster" >> /etc/ecs/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=15m" >> /etc/ecs/ecs.config
echo "ECS_IMAGE_CLEANUP_INTERVAL=10m" >> /etc/ecs/ecs.config
echo "ECS_INSTANCE_ATTRIBUTES={\"application\": \"kibana\"}" >> /etc/ecs/ecs.config

start ecs

echo "Done"

--==BOUNDARY==--
