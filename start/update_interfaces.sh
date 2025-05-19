#!/bin/bash

output=$(g5k-subnets -ingbm | head -n 1)
read -r SUBNET_ADDR SUBNET_BC SUBNET_NETMASK SUBNET_GW SUBNET_MAC <<< "$output"

EXP_NODE=$1

# setup network for dpdk by switching the subnet ip into the first interface
# for unknown reasons, DPDK accept connections through the first interface so thats why we switch the ip
# the first ip to the second interface
ssh root@$EXP_NODE "
    S_INT=\$(ip link show | grep '^[0-9]' | awk '{print \$2}' | sed 's/://' | grep -v '^lo$' | head -n 2 | tail -n 1);
    ifconfig \$S_INT  $SUBNET_ADDR netmask $SUBNET_NETMASK broadcast $SUBNET_BC hw ether $SUBNET_MAC;
"
