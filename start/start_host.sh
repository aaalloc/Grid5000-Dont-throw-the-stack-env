#!/bin/bash
set -e

#OAR -t deploy
#OAR -t destructive
#OAR -l slash_22=1+host=1


function get_current_interface_ip() {
    INTERFACES=$(ip link show | grep -v 'lo' | grep 'state UP' | awk '{print $2}' | tr -d ':')    
    IP=$(ip addr show $INTERFACES | grep 'inet ' | awk '{print $2}' | awk -F'/' '{print $1}')

    echo $IP
}

HOST_NODE_PATH=~/.ok_nodes_host
CLIENTS_NODES_PATH=~/.ok_nodes_client



kadeploy3 -a build/environment/environment.dsc --output-ok-nodes $HOST_NODE_PATH

EXP_NODE=$(cat $HOST_NODE_PATH | head -n 1)
NODES=$(cat $CLIENTS_NODES_PATH | tr "," "\n")
# path here is hardcoded for simplicity, be carefull so that in netstack conf it corresponds (mutilate.sh)
paste -sd, $CLIENTS_NODES_PATH  | ssh root@$EXP_NODE "cat > /home/work/mutilate_nodes"

ssh root@$EXP_NODE "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y"
PUB_KEY=$(ssh root@$EXP_NODE "cat ~/.ssh/id_rsa.pub")
for NODE in $NODES;
do
    ssh root@$NODE "echo $PUB_KEY >> ~/.ssh/authorized_keys"
done

# get first subnet info for dpdk
# Assuming the output of the command is stored in a variable
output=$(g5k-subnets -ingbm | head -n 1)
read -r SUBNET_ADDR SUBNET_BC SUBNET_NETMASK SUBNET_GW SUBNET_MAC <<< "$output"

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
    ifconfig \$F_INT $SUBNET_ADDR netmask $SUBNET_NETMASK broadcast $SUBNET_BC hw ether $SUBNET_MAC
"

# setup f-stack conf with right ip address
ssh root@$EXP_NODE "
    sed -i '/^port_list=1$/c\port_list=0' /home/work/netstack-exp/f-stack.conf
    sed -i '/^\[port1\]$/c\[port0\]' /home/work/netstack-exp/f-stack.conf
    sed "s/addr=192.168.199.1/addr=${SUBNET_ADDR}/" -i /home/work/netstack-exp/f-stack.conf
    sed "s/netmask=255.252.0.0/netmask=${SUBNET_NETMASK}/" -i /home/work/netstack-exp/f-stack.conf
    sed "s/broadcast=192.168.199.255/broadcast=${SUBNET_BC}/" -i /home/work/netstack-exp/f-stack.conf
    sed "s/gateway=192.168.199.99/gateway=${SUBNET_GW}/" -i /home/work/netstack-exp/f-stack.conf
"


# final step
ssh root@$EXP_NODE "
    bash /home/work/before-work.sh
"

sleep infinity