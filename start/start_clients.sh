#!/bin/bash

#OAR -t deploy

HOST_SITE=grenoble
NODES_CLIENT_FILE=~/.ok_nodes_client

kadeploy3 -a build/mutilate-environment/mutilate-environment.dsc --output-ok-nodes $NODES_CLIENT_FILE
scp $NODES_CLIENT_FILE $HOST_SITE:$NODES_CLIENT_FILE
ssh $HOST_SITE "oarsub -S ~/public/dont-throw-the-stack/start/start_host.sh"
# to make the container run forever until walltime is reached
sleep infinity