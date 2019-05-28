#!/bin/bash
# Set the ECS agent configuration options

yum install aws-cli -y

# Check for Elastic Network Interface
if [ -n ${eni_id+x} ]; then
# if 'in-use' then check every 30 seconds for 10 minutes to see if status changes. If no change, skip. If 'available' attach on current node.
  n=0
  until [ $n -ge 20 ] ; do
    eni_status=$(aws ec2 describe-network-interfaces --region ${region} --query NetworkInterfaces[*].Status --network-interface-ids ${eni_id} --output text)
    if [[ "${eni_status}" == "available" ]] ; then
      echo "ENI available, attaching..."
      aws ec2 attach-network-interface --network-interface-id ${eni_id} --instance-id ${instance_id} --device-index 1 --region ${region}
      break
    else
      echo "ENI in-use, sleeping and then checking again"
      n=$[$n+1]
      sleep 30
    fi
  done
else
  echo "ERROR: no elastic network interface is available in ${availability_zone} with eni_friendly_name tagged as ${eni_friendly_name}."
fi

#Host config
sysctl -w vm.max_map_count=262144
mkdir -p /usr/share/elasticsearch/data/
chown -R 1000.1000 /usr/share/elasticsearch/data/

# ECS config

echo "ECS_CLUSTER=ecs-cluster" >> /etc/ecs/ecs.config
echo "ECS_ENGINE_TASK_CLEANUP_WAIT_DURATION=15m" >> /etc/ecs/ecs.config
echo "ECS_IMAGE_CLEANUP_INTERVAL=10m" >> /etc/ecs/ecs.config

start ecs

echo "Done"

--==BOUNDARY==--
