#!/usr/bin/env bash

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
plan_file="plan"
principal='{ Service = "lambda.amazonaws.com" }'
resource='"*"'
app_name="lambdaTestRoleToCheckIfThisWorks${RANDOM}${RANDOM}"
action="\"s3:*\""

echo plan is successful
terraform plan -var "name=${app_name}" \
               -var "app_name=${app_name}" \
               -var "principal=${principal}" \
               -var "resource=${resource}" \
               -var "action=${action}" \
               -out "${plan_file}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve ${plan_file} 1>/dev/null || exit 1

echo resources are destroyed successfully
terraform destroy -auto-approve -var "name=${app_name}" \
                                -var "app_name=${app_name}" \
                                -var "principal=${principal}" \
                                -var "resource=${resource}" \
                                -var "action=${action}" 1>/dev/null || exit 1
echo SUCCESS
