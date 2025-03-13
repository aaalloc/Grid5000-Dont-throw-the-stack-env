#!/bin/bash

# update client nodes authorized_keys so that experience nodes can ssh into them

# arg1: name of exp node
# arg2: list of client nodes (space separated)

EXP_NODE=$1
NODES=$2

ssh root@$EXP_NODE "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y"
PUB_KEY=$(ssh root@$EXP_NODE "cat ~/.ssh/id_rsa.pub")
for NODE in $NODES;
do
    echo "Updating $NODE"
    ssh root@$NODE "echo $PUB_KEY >> ~/.ssh/authorized_keys"
done