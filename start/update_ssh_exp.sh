#!/bin/bash

# update client nodes authorized_keys so that experience nodes can ssh into them

# arg1: path to host node file
# arg2: path to client nodes file

HOST_NODE_PATH=$1
CLIENTS_NODES_PATH=$2

EXP_NODE=$(cat $HOST_NODE_PATH | head -n 1)
NODES=$(cat $CLIENTS_NODES_PATH | tr "," "\n")
# path here is hardcoded for simplicity, be carefull so that in netstack conf it corresponds (mutilate.sh)
echo $NODES | ssh root@$EXP_NODE "cat > /tmp/mutilate_nodes"

ssh root@$EXP_NODE "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y"
PUB_KEY=$(ssh root@$EXP_NODE "cat ~/.ssh/id_rsa.pub")
for NODE in $NODES;
do
    ssh root@$NODE "echo $PUB_KEY >> ~/.ssh/authorized_keys"
done