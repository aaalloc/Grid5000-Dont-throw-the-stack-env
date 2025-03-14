#!/bin/bash

output=$(g5k-subnets -ingbm | head -n 1)
read -r SUBNET_ADDR SUBNET_BC SUBNET_NETMASK SUBNET_GW SUBNET_MAC <<< "$output"

EXP_NODE=$1

# setup network for dpdk by switching the subnet ip into the first interface
# for unknown reasons, DPDK accept connections through the first interface so thats why we switch the ip
# the first ip to the second interface
ssh root@$EXP_NODE "
    F_INT=\$(ip link show up | grep '^[0-9]' | awk '{print \$2}' | sed 's/://' | grep -v '^lo$' | head -n 1);
    S_INT=\$(ip link show | grep '^[0-9]' | awk '{print \$2}' | sed 's/://' | grep -v '^lo$' | head -n 2 | tail -n 1);
    myaddr=\$(ifconfig \$F_INT | grep "inet" | grep -v ":" | awk -F ' '  '{print \$2}');
    mymask=\$(ifconfig \$F_INT | grep "netmask" | awk -F ' ' '{print \$4}');
    mybc=\$(ifconfig \$F_INT | grep "broadcast" | awk -F ' ' '{print \$6}');
    ifconfig \$S_INT \$myaddr netmask \$mymask broadcast \$mybc;
    ifconfig \$F_INT $SUBNET_ADDR netmask $SUBNET_NETMASK broadcast $SUBNET_BC hw ether $SUBNET_MAC;
    dhclient \$S_INT
"
