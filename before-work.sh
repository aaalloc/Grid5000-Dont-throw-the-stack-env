#!/bin/bash

ENV=$1
if [ -z $ENV ]; then
    echo "Please provide the environment name"
    exit 1
fi

case $ENV in
    environment|environment-caladan)
        ;;
    *)
        echo "Please provide a valid environment name (environment or environment-caladan)"
        exit 1
        ;;
esac

# update linux tools
bash /home/work/update-linux-tools.sh


# fix dpdk install for f-stack
if [ $ENV == "environment" ]; then
    cd /home/work/f-stack/dpdk
    sudo ninja -C build install
    cd ../lib
    sudo make
    sudo make install
fi

echo "everythings ok"