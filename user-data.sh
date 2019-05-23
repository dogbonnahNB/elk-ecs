Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==

Content-Type: text/cloud-boothook; charset="us-ascii"
# Set Docker daemon options
cloud-init-per once docker_options echo 'OPTIONS="${OPTIONS} --storage-opt dm.basesize=20G"' >> /etc/sysconfig/docker

--==BOUNDARY==

Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
# Set the ECS agent configuration options

#Host config
sysctl -w vm.max_map_count=262144
mkdir -p /usr/share/elasticsearch/data/
chown -R 1000.1000 /usr/share/elasticsearch/data/

# ECS config

echo "ECS_CLUSTER=fast-cluster" >> /etc/ecs/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=15m" >> /etc/ecs/ecs.config
echo "ECS_IMAGE_CLEANUP_INTERVAL=10m" >> /etc/ecs/ecs.config

start ecs

echo "Done"

--==BOUNDARY==--
