#!/usr/bin/env bash

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
plan_file="plan"

echo plan is successful
terraform plan -out "${plan_file}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve "${plan_file}" 1>/dev/null || { terraform destroy -auto-approve 1>/dev/null; exit 1; }

echo resources are destroyed successfully
terraform destroy -auto-approve 1>/dev/null || exit 1
echo SUCCESS
