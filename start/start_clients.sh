#!/bin/bash

OK_NODES_PATH=.ok_client_nodes

function start_client_nodes {
    # where we initiate packet sending with stresstest tool

    # arg1: client grid5000 site
    # arg2: number of clients
    # arg3: duration of holding hosts
    # arg3: client environment path for kadeploy3

    CLIENT_GRID5000_SITE=$1
    NUM_CLIENTS=$2
    DURATION=$3
    CLIENT_ENV_PATH=$4


    ssh -tt $CLIENT_GRID5000_SITE << EOF
oarsub -I -t deploy -l host=$NUM_CLIENTS,walltime=$DURATION
kadeploy3 $CLIENT_ENV_PATH --output-ok-nodes $OK_NODES_PATH
EOF
    echo "Client nodes are ready to be used"
}

start_client_nodes $CLIENT_GRID5000_SITE $NUM_CLIENTS $DURATION $CLIENT_ENV_PATH