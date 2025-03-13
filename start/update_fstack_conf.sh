#!/bin/bash
output=$(g5k-subnets -ingbm | head -n 1)
read -r SUBNET_ADDR SUBNET_BC SUBNET_NETMASK SUBNET_GW SUBNET_MAC <<< "$output"

EXP_NODE=$1
FSTACK_PATH=$2

# setup f-stack conf with right ip address
ssh root@$EXP_NODE "
    sed -i '/^port_list=1$/c\port_list=0' $FSTACK_PATH
    sed -i '/^\[port1\]$/c\[port0\]' $FSTACK_PATH
    sed "s/addr=192.168.199.1/addr=${SUBNET_ADDR}/" -i $FSTACK_PATH
    sed "s/netmask=255.255.255.0/netmask=${SUBNET_NETMASK}/" -i $FSTACK_PATH
    sed "s/broadcast=192.168.199.255/broadcast=${SUBNET_BC}/" -i $FSTACK_PATH
    sed "s/gateway=192.168.199.99/gateway=${SUBNET_GW}/" -i $FSTACK_PATH
"
