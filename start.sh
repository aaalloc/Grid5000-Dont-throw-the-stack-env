#!/bin/bash


function get_current_interface_ip() {
    INTERFACES=$(ip link show | grep -v 'lo' | grep 'state UP' | awk '{print $2}' | tr -d ':')    
    IP=$(ip addr show $INTERFACES | grep 'inet ' | awk '{print $2}' | awk -F'/' '{print $1}')

    echo $IP
}

function start_host_node() {
    # where we measure received packet performances
    
    # arg1: grid5000 site
    # arg2: client nodes hostnames (needed for initiating stresstest from host)
    # arg3: duration of holding host
    # arg4: client environment path for kadeploy3
    GRID5000_SITE=$1
    CLIENT_NODES=$2
    DURATION=$3
    HOST_ENV_PATH=$4
    ssh -tt $GRID5000_SITE << EOF
    oarsub -I -t deploy -l host=1,walltime=$DURATION
    kadeploy3 -a $HOST_ENV_PATH
    kareboot3 simple --custom-steps public/dont-throw-the-stack/v5.15.79-kernel-polling-load.yml
    ssh -tt root@\$(oarprint host) << EOF
        bash /home/work/before-work.sh
        exec env NODES="$CLIENT_NODES" /bin/bash
    EOF 
EOF
}

function start_client_nodes {
    # where we initiate packet sending with stresstest tool

    # arg1: grid5000 site
    # arg2: number of clients
    # arg3: duration of holding hosts
    # arg4: client environment path for kadeploy3

    # return: controller node and client nodes as "controller_node client_node1 client_node2 ..."
    GRID5000_SITE=$1
    NUM_CLIENTS=$2
    DURATION=$3
    CLIENT_ENV_PATH=$4
    # TODO: fix this, it will stuck and no follow execution
    # an idea will be to run this not in interactive (remember oarsub -S with #OAR....)
    # then wait that they are responsive and then continue

    NODES=$(ssh -tt $GRID5000_SITE << EOF 
    oarsub -I -t deploy -l host=$NUM_CLIENTS,walltime=$DURATION
    kadeploy3 -a $CLIENT_ENV_PATH
    oarprint host | paste -sd ","
EOF
)
    # in nodes, we need to have only one node as a controller for further test, so we will choose the first one and split the rest
    CONTROLLER_NODE=$(echo $NODES | cut -d "," -f 1)
    CLIENT_NODES=$(echo $NODES | cut -d "," -f 2-)
 
    # here we will install ssh keys for the client nodes into the controller node 
    # so the controller node can ssh into the client nodes
    for NODE in $CLIENT_NODES;
    do
        ssh root@$NODE "ssh-keygen"
        PUB_KEY=$(ssh root@$NODE "cat ~/.ssh/id_rsa.pub")
        ssh root@$CONTROLLER_NODE "echo $PUB_KEY >> ~/.ssh/authorized_keys"
    done


    # here we will have to return the controller node and the client nodes
    echo "$CONTROLLER_NODE $CLIENT_NODES"
}

HOST_GRID5000_SITE="sophia"
CLIENT_GRID5000_SITE="grenoble"

DURATION=1
NUM_CLIENTS=2

HOST_ENV_PATH="/home/ayanovsk/environment.yml"
CLIENT_ENV_PATH="/home/ayanovsk/mutilate-environment.yml"

NODES=$(start_client_nodes $CLIENT_GRID5000_SITE $NUM_CLIENTS $DURATION $CLIENT_ENV_PATH)
start_host_node $HOST_GRID5000_SITE $NODES $DURATION $HOST_ENV_PATH