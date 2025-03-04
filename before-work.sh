#!/bin/bash

# update linux tools
bash /home/work/update-linux-tools.sh


# load kernel module
bash /home/work/load-driver.sh


# fix dpdk install
cd /home/work/f-stack/dpdk
ninja -C build install
cd ../lib
make install

echo "everythings ok"