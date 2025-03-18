#!/bin/bash
set -e

#OAR -t deploy
#OAR -t destructive
#OAR -l slash_22=1+host=1


function get_current_interface_ip() {
    INTERFACES=$(ip link show | grep -v 'lo' | grep 'state UP' | awk '{print $2}' | tr -d ':')    
    IP=$(ip addr show $INTERFACES | grep 'inet ' | awk '{print $2}' | awk -F'/' '{print $1}')

    echo $IP
}

HOST_NODE_PATH=~/.ok_nodes_host
CLIENTS_NODES_PATH=~/.ok_nodes_client

ENV=environment-caladan
# ENV=environment
# ENV=environment-polling

# environment polling is just environment but with extra steps
if [ $ENV == "environment-polling"]; then
    kadeploy3 -a build/environment/environment.dsc --output-ok-nodes $HOST_NODE_PATH
else
    kadeploy3 -a build/$ENV/$ENV.dsc --output-ok-nodes $HOST_NODE_PATH
fi

EXP_NODE=$(cat $HOST_NODE_PATH | head -n 1)
NODES=$(cat $CLIENTS_NODES_PATH | tr "," "\n")
# path here is hardcoded for simplicity, be carefull so that in netstack conf it corresponds (mutilate.sh)
paste -sd, $CLIENTS_NODES_PATH  | ssh root@$EXP_NODE "cat > /home/work/mutilate_nodes"

~/public/dont-throw-the-stack/start/update_ssh_exp.sh $EXP_NODE "${NODES}"
if [ $ENV == "environment" ] || [ $ENV == "environment-caladan" ]; then
    ~/public/dont-throw-the-stack/start/update_interfaces.sh $EXP_NODE
fi

if [ $ENV == "environment" ]; then
    ~/public/dont-throw-the-stack/start/update_fstack_conf.sh $EXP_NODE /home/work/netstack-exp/f-stack.conf
elif [ $ENV == "environment-caladan" ]; then
    ~/public/dont-throw-the-stack/start/update_caladan_conf.sh $EXP_NODE /home/work/netstack-exp/caladan.config
elif [ $ENV == "environment-polling" ]; then
    ~/public/dont-throw-the-stack/start/compile_linux_kernel.sh $EXP_NODE /home/work/linux-5.15.79
    kareboot3 simple --custom-steps ~/public/dont-throw-the-stack/v5.15.79-kernel-load.yml
fi

# final step
ssh root@$EXP_NODE "
    bash /home/work/before-work.sh $ENV
"

sleep infinity