#!/bin/bash
set -e

#OAR -t deploy
#OAR -t destructive
#OAR -l slash_22=1+host=1


HOST_NODE_PATH=~/.ok_nodes_host
CLIENTS_NODES_PATH=~/.ok_nodes_client

case "$1" in
    "")
        echo "Set default value to caladan"
        ENV=caladan
        ;;
    caladan|fstack|polling)
        ENV=$1
        ;;
    *)
        echo "Please provide a valid environment name (caladan, fstack, polling)"
        exit 1
        ;;
esac

kadeploy3 -a build/environment/environment.dsc --output-ok-nodes $HOST_NODE_PATH


EXP_NODE=$(cat $HOST_NODE_PATH | head -n 1)
NODES=$(cat $CLIENTS_NODES_PATH | tr "," "\n")
# path here is hardcoded for simplicity, be carefull so that in netstack conf it corresponds (mutilate.sh)
paste -sd, $CLIENTS_NODES_PATH  | ssh root@$EXP_NODE "cat > /home/work/mutilate_nodes"

~/public/dont-throw-the-stack/start/update_ssh_exp.sh $EXP_NODE "${NODES}"
if [ $ENV == "fstack" ] || [ $ENV == "caladan" ]; then
    ~/public/dont-throw-the-stack/start/update_interfaces.sh $EXP_NODE
fi


case $ENV in
    caladan)
        ~/public/dont-throw-the-stack/start/update_caladan_conf.sh $EXP_NODE /home/work/netstack-exp/caladan.config
        ;;
    fstack)
        ~/public/dont-throw-the-stack/start/update_fstack_conf.sh $EXP_NODE /home/work/netstack-exp/f-stack.conf
        ;;
    polling)
        ~/public/dont-throw-the-stack/start/compile_linux_kernel.sh $EXP_NODE /home/work/linux-5.15.79
        kareboot3 simple --custom-steps ~/public/dont-throw-the-stack/v5.15.79-kernel-load.yml
        ;;
    *)
        echo "Please provide a valid environment name (environment or environment-caladan)"
        exit 1
        ;;
esac

# final step
ssh root@$EXP_NODE "
    bash /home/work/before-work.sh $ENV
"

sleep infinity