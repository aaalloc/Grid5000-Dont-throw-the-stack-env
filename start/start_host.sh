#!/bin/bash
set -e

#OAR -t deploy
#OAR -t destructive
#OAR -p 'cputype=Intel Xeon E5-2650 v2'


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
echo $NODES | ssh root@$EXP_NODE "cat > /tmp/mutilate_nodes"

ssh root@$EXP_NODE "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y"
PUB_KEY=$(ssh root@$EXP_NODE "cat ~/.ssh/id_rsa.pub")
for NODE in $NODES;
do
    ssh root@$NODE "echo $PUB_KEY >> ~/.ssh/authorized_keys"
done
sleep infinity