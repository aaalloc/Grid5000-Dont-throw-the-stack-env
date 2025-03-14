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



kadeploy3 -a build/$ENV/$ENV.dsc --output-ok-nodes $HOST_NODE_PATH

EXP_NODE=$(cat $HOST_NODE_PATH | head -n 1)
NODES=$(cat $CLIENTS_NODES_PATH | tr "," "\n")
# path here is hardcoded for simplicity, be carefull so that in netstack conf it corresponds (mutilate.sh)
paste -sd, $CLIENTS_NODES_PATH  | ssh root@$EXP_NODE "cat > /home/work/mutilate_nodes"

~/public/dont-throw-the-stack/start/update_ssh_exp.sh $EXP_NODE "${NODES}"
~/public/dont-throw-the-stack/start/update_interfaces.sh $EXP_NODE
~/public/dont-throw-the-stack/start/update_fstack_conf.sh $EXP_NODE /home/work/netstack-exp/f-stack.conf

# final step
ssh root@$EXP_NODE "
    bash /home/work/before-work.sh
"

sleep infinity