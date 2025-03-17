#!/bin/bash

ENV=$1
if [ -z $ENV ]; then
    echo "Please provide the environment name"
    exit 1
fi

# env needs to be either environment or environment-caladan
if [ $ENV != "environment" ] && [ $ENV != "environment-caladan" ]; then
    echo "Please provide a valid environment name (environment or environment-caladan)"
    exit 1
fi

# update linux tools
bash /home/work/update-linux-tools.sh


# load kernel module
# bash /home/work/load-driver.sh


# fix dpdk install for f-stack
if [ $ENV == "environment" ]; then
    cd /home/work/f-stack/dpdk
    sudo ninja -C build install
    cd ../lib
    sudo make
    sudo make install
fi

echo "everythings ok"