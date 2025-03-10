#!/bin/bash
set -e

#OAR -t deploy

HOST_SITE=sophia
NODES_CLIENT_FILE=~/.ok_nodes_client

kadeploy3 -a build/mutilate-environment/mutilate-environment.dsc --output-ok-nodes $NODES_CLIENT_FILE
scp $NODES_CLIENT_FILE $HOST_SITE:$NODES_CLIENT_FILE
ssh $HOST_SITE "oarsub -S ~/public/dont-throw-the-stack/start/start_host.sh"
# to make the container run forever until walltime is reached
sleep infinity

oarsub -t deploy -l host=2,walltime=2 "kadeploy3 -a build/mutilate-environment/mutilate-environment.dsc --output-ok-nodes ~/.ok_nodes_client; \
    scp ~/.ok_nodes_client sophia:~/.ok_nodes_client; \
    sleep infinity"