#!/usr/bin/env bash

exit 0

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
app_name="ec2ltlbasg${RANDOM}"
vpc_id="vpc-96542efe"
vpc_subnet_id="subnet-93a129e9"
vpc_subnet_ids='["subnet-93a129e9", "subnet-ef8bc786", "subnet-2a7ea166"]'
AZs='["eu-west-2a", "eu-west-2b", "eu-west-2c"]'
ec2_image_id='ami-00024466c99c4042e'
plan_file=plan

echo plan is successful
terraform plan -var "app_name=${app_name}" \
               -var "vpc_id=${vpc_id}" \
               -var "vpc_subnet_id=${vpc_subnet_id}" \
               -var "vpc_subnet_ids=${vpc_subnet_ids}" \
               -var "AZs=${AZs}" \
               -var "ec2_image_id=${ec2_image_id}" \
               -out "${plan_file}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve ${plan_file} 1>/dev/null || exit 1

echo resources are destroyed successfully
terraform destroy -auto-approve \
                  -var "app_name=${app_name}" \
                  -var "vpc_id=${vpc_id}" \
                  -var "vpc_subnet_id=${vpc_subnet_id}" \
                  -var "vpc_subnet_ids=${vpc_subnet_ids}" \
                  -var "AZs=${AZs}" \
                  -var "ec2_image_id=${ec2_image_id}" 1>/dev/null || exit 1
echo SUCCESS
