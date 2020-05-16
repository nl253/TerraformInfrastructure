#!/usr/bin/env bash

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
plan_file="plan"
app_name="fargateJenkinsApp${RANDOM}${RANDOM}"

echo plan is successful
terraform plan -var "app_name=${app_name}" \
               -out "${plan_file}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve ${plan_file} 1>/dev/null || exit 1

echo resources are destroyed successfully

terraform destroy -auto-approve -var "app_name=${app_name}" 1>/dev/null || echo failed to destry on frist attempt
terraform destroy -auto-approve -var "app_name=${app_name}" 1>/dev/null || exit 1

echo SUCCESS
