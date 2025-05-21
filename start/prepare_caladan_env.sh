#!/bin/bash

# after the env has been kadeployed, this script will be run on the caladan node

EXP_NODE=$1
PATH_REPO=~/public/dont-throw-the-stack

$PATH_REPO/start/update_omnipath_interface.sh $EXP_NODE
IP_OPA=$(ssh root@$EXP_NODE "ip addr show | grep -o -P '^\d+: ibp\w+' | head -n 1 | awk '{print \$2}'")

ssh root@$EXP_NODE "
    cd /project/caladan
    make submodules
    sed -i 's/#define DPDK_PORT 1/#define DPDK_PORT 0/' iokernel/dpdk.c
    make -j \$(nproc) CONFIG_SPDK=y
    ./scripts/setup_machine.sh
    ./spdk/scripts/setup.sh
    cd ..
    PKG_CONFIG_PATH=./caladan/rdma-core/build/lib/pkgconfig:./caladan/dpdk/build/lib/x86_64-linux-gnu/pkgconfig:./caladan/spdk/build/lib/pkgconfig: meson setup build -Dcaladan=true -Dbuild_server_caladan=true
"


echo "Use $IP_OPA to connect to the caladan node"


# ssh root@$IP_OPA '
#     cd /project/caladan
#     ./iokerneld simple nobw noht &
# "
