#!/bin/bash

# This script can be run ONLY IF the EFS is not attached to /data AND IF the EBS volume that is attached to / is not the one that is managed bv terraform
# Most likely after the instance has been terminated due to changes in terraform configuration

set -e

instance_id="$(terraform state pull | command grep -E -o 'spot_instance_id":\s*"[^"]*"' | sed -E 's/\s+//g' | sed -E 's/spot_instance_id":\s*//' | sed -E 's/"//g')"

aws ec2 stop-instances --instance-ids "${instance_id}"

old_volume_id="$(terraform state pull | command grep -E -o 'volume_id":\s*"[^"]*"' | sed -E 's/volume_id":\s*//' | sed -E 's/"//g')"
new_volume_id="$(terraform state pull | command grep -E -o 'volume/vol-[^"]*' | sed -E 's/volume\///')"
efs_id="$(terraform state pull | command grep -E -o 'fs-\w+' | uniq)"
region="eu-west-2"
efs_mount_point="/data"
device="/dev/sda1"

sleep 80

aws ec2 detach-volume --instance-id "${instance_id}" --volume-id "${old_volume_id}"
aws ec2 delete-volume --volume-id "${old_volume_id}"
aws ec2 attach-volume --instance-id "${instance_id}" --volume-id "${new_volume_id}" --device "${device}"

sleep 80

aws ec2 start-instances --instance-ids "${instance_id}"

sleep 120

ssh linux.norbert-logiewa.co.uk "mkdir -p $efs_mount_point && apt update && apt install -y git nfs-{common,kernel-server} curl wget vim sed && mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${efs_id}.efs.${region}.amazonaws.com:/ $efs_mount_point"
