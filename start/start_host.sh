#!/bin/bash

#OAR -t deploy
#OAR -t destructive


function get_current_interface_ip() {
    INTERFACES=$(ip link show | grep -v 'lo' | grep 'state UP' | awk '{print $2}' | tr -d ':')    
    IP=$(ip addr show $INTERFACES | grep 'inet ' | awk '{print $2}' | awk -F'/' '{print $1}')

    echo $IP
}

HOST_PATH=~/.ok_exp_host
CLIENTS_PATH=~/.ok_nodes_client

kadeploy3 ubuntu2204-min --output-ok-nodes $HOST_PATH
EXP_NODE=$(cat $HOST_PATH | head -n 1)
NODES=$(cat $CLIENTS_PATH | tr "," "\n")
for NODE in $NODES;
do
    ssh root@$NODE "ssh-keygen"
    PUB_KEY=$(ssh root@$NODE "cat ~/.ssh/id_rsa.pub")
    ssh root@$EXP_NODE "echo $PUB_KEY >> ~/.ssh/authorized_keys"
done
sleep infinity