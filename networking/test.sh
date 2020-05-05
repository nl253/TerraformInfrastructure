#!/usr/bin/env bash

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
appName="TestApp${RANDOM}${RANDOM}"
hostPrefix="192.168"
cidrVpc="${hostPrefix}.0.0/16"
cidrPublic="${hostPrefix}.0.0/24"
cidrPrivate="${hostPrefix}.2.0/23"
planFile="plan"

echo plan is successful
terraform plan -var "appName=${appName}" \
               -var "cidrVpc=${cidrVpc}" \
               -var "cidrPublic=${cidrPublic}" \
               -var "cidrPrivate=${cidrPrivate}" \
               -out "${planFile}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve "${planFile}" 1>/dev/null || exit 1

echo resources are destroyed successfully
terraform destroy -auto-approve -var "appName=${appName}" \
                                -var "cidrVpc=${cidrVpc}" \
                                -var "cidrPublic=${cidrPublic}" \
                                -var "cidrPrivate=${cidrPrivate}" 1>/dev/null || exit 1
echo SUCCESS
