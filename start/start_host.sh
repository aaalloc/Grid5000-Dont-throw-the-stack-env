#!/bin/bash
set -e

#OAR -t deploy
#OAR -t destructive
#OAR -l slash_22=1+host=1

PATH_REPO=~/public/dont-throw-the-stack
HOST_NODE_PATH=~/.ok_nodes_host
CLIENTS_NODES_PATH=~/.ok_nodes_client
CONF=env_kernel_bypass
CONF_PATH=~/build/$CONF/$CONF.dsc

case "$1" in
    "")
        echo "Set default value to caladan"
        ENV=caladan
        ;;
    caladan|fstack)
        ENV=$1
        ;;
    *)
        echo "Please provide a valid environment name (caladan, fstack)"
        exit 1
        ;;
esac

if [ ! -f $CONF_PATH ]; then
    echo "Please build the environment first"
    exit 1
fi

kadeploy3 -a $CONF_PATH --output-ok-nodes $HOST_NODE_PATH


EXP_NODE=$(cat $HOST_NODE_PATH | head -n 1)
NODES=$(cat $CLIENTS_NODES_PATH | tr "," "\n")
# path here is hardcoded for simplicity, be carefull so that in netstack conf it corresponds (mutilate.sh)
paste -sd, $CLIENTS_NODES_PATH  | ssh root@$EXP_NODE "cat > /home/work/mutilate_nodes"

$PATH_REPO/start/update_ssh_exp.sh $EXP_NODE "${NODES}"
if [ $ENV == "fstack" ] || [ $ENV == "caladan" ]; then
    $PATH_REPO/start/update_interfaces.sh $EXP_NODE
fi


case $ENV in
    caladan)
        $PATH_REPO/start/update_caladan_conf.sh $EXP_NODE /home/work/caladan/server.config
        ;;
    fstack)
        $PATH_REPO/start/update_fstack_conf.sh $EXP_NODE /home/work/f-stack/f-stack.conf
        ;;
    *)
        echo "Please provide a valid environment name (environment or environment-caladan)"
        exit 1
        ;;
esac

sleep infinity