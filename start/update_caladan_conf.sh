#!/bin/bash
output=$(g5k-subnets -ingbm | head -n 1)
read -r SUBNET_ADDR SUBNET_BC SUBNET_NETMASK SUBNET_GW SUBNET_MAC <<< "$output"

EXP_NODE=$1
CALADAN_PATH=$2

ssh root@$EXP_NODE "
    sed "s/host_addr 192.168.199.1/host_addr ${SUBNET_ADDR}/" -i $CALADAN_PATH
    sed "s/host_netmask 255.255.255.0/host_netmask ${SUBNET_NETMASK}/" -i $CALADAN_PATH
    sed "s/host_gateway 192.168.199.1/host_gateway ${SUBNET_GW}/" -i $CALADAN_PATH
"
