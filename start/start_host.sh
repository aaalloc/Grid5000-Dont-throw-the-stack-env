#!/bin/bash


function get_current_interface_ip() {
    INTERFACES=$(ip link show | grep -v 'lo' | grep 'state UP' | awk '{print $2}' | tr -d ':')    
    IP=$(ip addr show $INTERFACES | grep 'inet ' | awk '{print $2}' | awk -F'/' '{print $1}')

    echo $IP
}

function update_client_ssh() {
    # here we will install ssh keys for the client nodes into the experience node 
    # so the experience node can ssh into the client nodes (for mutilate tool)

    # arg1: path file of nodes (nodes will be seperated by new line)
    # arg2: experience node
    EXP_NODE=$(cat $OK_EXP_NODES_PATH | head -n 1)
    NODES=$(cat $OK_NODES_CLIENT_PATH | tr "," "\n")
    for NODE in $NODES;
    do
        ssh root@$NODE "ssh-keygen"
        PUB_KEY=$(ssh root@$NODE "cat ~/.ssh/id_rsa.pub")
        ssh root@$EXP_NODE "echo $PUB_KEY >> ~/.ssh/authorized_keys"
    done
}

function start_host_node() {
    # where we measure received packet performances
    
    # arg1: grid5000 site
    # arg2: duration of holding host
    # arg3: client environment path for kadeploy3
    GRID5000_SITE=$1
    DURATION=$2
    HOST_ENV_PATH=$3

    ssh -tt $GRID5000_SITE << EOF
$(typeset -f update_client_ssh)
oarsub -I -t deploy -l host=1,walltime=$DURATION
kadeploy3 $HOST_ENV_PATH --output-ok-nodes $OK_EXP_NODES_PATH
update_client_ssh $OK_NODES_PATH 
EOF
}


start_host_node $HOST_GRID5000_SITE $DURATION $HOST_ENV_PATH