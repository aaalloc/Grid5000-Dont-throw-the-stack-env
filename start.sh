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
    ssh $GRID5000_SITE /bin/bash << EOF
    oarsub -I -t deploy -l host=1,walltime=$DURATION
    kadeploy3 -a $HOST_ENV_PATH
    kareboot3 simple --custom-steps public/dont-throw-the-stack/v5.15.79-kernel-polling-load.yml
    ssh root@$(oarprint host) /bin/bash << EOF
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
    GRID5000_SITE=$1
    NUM_CLIENTS=$2
    DURATION=$3
    CLIENT_ENV_PATH=$4
    NODES=$(ssh $GRID5000_SITE /bin/bash << EOF 
    oarsub -I -t deploy -l host=$NUM_CLIENTS,walltime=$DURATION
    kadeploy3 -a $CLIENT_ENV_PATH
    oarprint host | paste -sd ","
EOF
)

    echo $NODES
}

HOST_GRID5000_SITE="sophia"
CLIENT_GRID5000_SITE="grenoble"

DURATION=1
NUM_CLIENTS=2

HOST_ENV_PATH="/home/ayanovsk/environment.yml"
CLIENT_ENV_PATH="/home/ayanovsk/mutilate-environment.yml"

NODES=$(start_client_nodes $CLIENT_GRID5000_SITE $NUM_CLIENTS $DURATION $CLIENT_ENV_PATH)
start_host_node $HOST_GRID5000_SITE $NODES $DURATION $HOST_ENV_PATH