#!/usr/bin/env bash

echo given valid configuration is provided
terraform validate 1>/dev/null || exit 1

echo given valid input vars are provided
appName="TestApp${RANDOM}${RANDOM}"
cidrVpc="192.168.0.0/16"
cidrPublic="192.168.0.0/24"
cidrPrivate="192.168.1.0/24"

echo plan is successful
terraform plan -var "appName=${appName}" \
               -var "cidrVpc=${cidrVpc}" \
               -var "cidrPublic=${cidrPublic}" \
               -var "cidrPrivate=${cidrPrivate}" 1>/dev/null || exit 1

echo configuration is applied successfully
terraform apply -auto-approve -var "appName=${appName}" \
                              -var "cidrVpc=${cidrVpc}" \
                              -var "cidrPublic=${cidrPublic}" \
                              -var "cidrPrivate=${cidrPrivate}" 1>/dev/null || exit 1

echo resources are destroyed successfully
terraform destroy -auto-approve -var "appName=${appName}" \
                                -var "cidrVpc=${cidrVpc}" \
                                -var "cidrPublic=${cidrPublic}" \
                                -var "cidrPrivate=${cidrPrivate}" 1>/dev/null || exit 1
echo SUCCESS
