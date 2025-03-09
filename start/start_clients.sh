#!/bin/bash

HOST_SITE=sophia
NODES_CLIENT_FILE=~/.ok_nodes_client

#OAR -t deploy
kadeploy3 ubuntu2204-min --output-ok-nodes $NODES_CLIENT_FILE
# to make the container run forever until walltime is reached
scp $NODES_CLIENT_FILE $HOST_SITE:$NODES_CLIENT_FILE
ssh $HOST_SITE "oarsub -S ~/public/dont-throw-out-the-stack/start/start_host.sh"
sleep infinity