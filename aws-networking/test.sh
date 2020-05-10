#!/usr/bin/env bash

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
app_name="TestApp${RANDOM}${RANDOM}"
host_prefix="192.168"
cidr_vpc="${host_prefix}.0.0/16"
cidr_public="${host_prefix}.0.0/24"
cidr_private="${host_prefix}.2.0/23"
plan_file="plan"

echo plan is successful
terraform plan -var "app_name=${app_name}" \
               -var "cidr_vpc=${cidr_vpc}" \
               -var "cidr_public=${cidr_public}" \
               -var "cidr_private=${cidr_private}" \
               -out "${plan_file}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve "${plan_file}" 1>/dev/null || exit 1

echo resources are destroyed successfully
terraform destroy -auto-approve -var "app_name=${app_name}" \
                                -var "cidr_vpc=${cidr_vpc}" \
                                -var "cidr_public=${cidr_public}" \
                                -var "cidr_private=${cidr_private}" 1>/dev/null || exit 1
echo SUCCESS
