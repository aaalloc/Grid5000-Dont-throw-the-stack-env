#!/bin/bash
output=$(g5k-subnets -ingbm | head -n 1)
read -r SUBNET_ADDR SUBNET_BC SUBNET_NETMASK SUBNET_GW SUBNET_MAC <<< "$output"

EXP_NODE=$1
CALADAN_PATH=$2

ssh root@$EXP_NODE "
    sed -i 's/host_addr .*/host_addr ${SUBNET_ADDR}/' $CALADAN_PATH
    sed -i 's/host_netmask .*/host_netmask ${SUBNET_NETMASK}/' $CALADAN_PATH
    sed -i 's/host_gateway .*/host_gateway ${SUBNET_GW}/' $CALADAN_PATH
"
