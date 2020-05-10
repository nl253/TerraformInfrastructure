#!/usr/bin/env bash

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
app_name="TestApp${RANDOM}${RANDOM}"
bucket="my-special-bucket-for-storing-stuff-${RANDOM}"
logging_bucket="logs-nl"
plan_file="plan"

echo plan is successful
terraform plan -var "app_name=${app_name}" \
               -var "logging_bucket=${logging_bucket}" \
               -var "bucket_name=${bucket}" \
               -out "${plan_file}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve "${plan_file}" 1>/dev/null || exit 1

echo resources are destroyed successfully
terraform destroy -auto-approve \
               -var "app_name=${app_name}" \
               -var "logging_bucket=${logging_bucket}" \
               -var "bucket_name=${bucket}" 1>/dev/null || exit 1
echo SUCCESS
