#!/usr/bin/env bash

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
principal='{ Service = "lambda.amazonaws.com" }'
resource='"*"'
name="lambdaTestRoleToCheckIfThisWorks${RANDOM}"
action="\"s3:*\""

echo when plan is successful
terraform plan -var "name=${name}" -var "principal=${principal}" -var "resource=${resource}" -var "action=${action}" 1>/dev/null || exit 1

echo and configuration is applied successfully
terraform apply -auto-approve -var "name=${name}" -var "principal=${principal}" -var "resource=${resource}" -var "action=${action}" 1>/dev/null || exit 1

echo resources that were created are in AWS
result=$(aws iam list-roles --query "Roles[?RoleName == '${name}']")

if [[ ${result} == '[]' ]]; then
  echo failed to find role $name
  exit 1
fi

echo when resources are destroyed successfully
terraform destroy -auto-approve -var "name=${name}" -var "principal=${principal}" -var "resource=${resource}" -var "action=${action}" 1>/dev/null || exit 1

echo resources that were created are no longer in AWS
result=$(aws iam list-roles --query "Roles[?RoleName == '${name}']")

if [[ ! ${result} == '[]' ]]; then
  echo failed to destroy role $name
  exit 1
fi

echo SUCCESS
