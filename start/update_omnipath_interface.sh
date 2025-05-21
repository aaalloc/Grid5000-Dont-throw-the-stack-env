#!/bin/bash
# This script is intended to be used on troll nodes only !

EXP_NODE=$1

IP_OPA=$(ssh root@$EXP_NODE "
    INTERFACE=\$(ip link show | grep -o -P '^\d+: ibp\w+' | head -n 1 | awk '{print \$2}')
    HOSTNAME=\$(hostname -s)
    N=\$(echo "\$HOSTNAME" | grep -o -E '[0-9]+$')
    ip link set "\$INTERFACE" up
    ip addr add "172.18.21.\$N/20" broadcast 172.18.31.255 dev "\$INTERFACE"
    echo "172.18.21.\$N/20"
")

echo $IP_OPA
# 172.18.20.2/20 brd 172.18.31.255
# => dahu-2

# 172.18.21.2/20 brd 172.18.31.255
# => troll-2