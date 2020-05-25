#!/usr/bin/env bash

exit 0

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
app_name="rdsTestApp${RANDOM}${RANDOM}"
db_name=mydatabase
db_engine=postgres
db_cluster_name=my-database-cluster
db_username=ma
db_password=pass123456
plan_file=plan

echo plan is successful
terraform plan -var "app_name=${app_name}" \
               -var "db_name=${db_name}" \
               -var "db_engine=${db_engine}" \
               -var "db_username=${db_username}" \
               -var "db_password=${db_password}" \
               -out "${plan_file}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve ${plan_file} 1>/dev/null || exit 1

echo resources are destroyed successfully
terraform destroy -auto-approve \
                  -var "app_name=${app_name}" \
                  -var "db_name=${db_name}" \
                  -var "db_engine=${db_engine}" \
                  -var "db_username=${db_username}" \
                  -var "db_password=${db_password}" 1>/dev/null || exit 1
echo SUCCESS
