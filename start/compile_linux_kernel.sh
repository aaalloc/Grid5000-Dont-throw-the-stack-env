#!/bin/bash

SSH=$1
KERNEL_PATH=$2

ssh root@$SSH "
    cd $KERNEL_PATH
    git apply /home/work/kernel-polling-5.15.79-base.patch
    git apply /home/work/mlx4-driver.patch
    yes "" | make localmodconfig
    scripts/config --disable SYSTEM_TRUSTED_KEYS
    scripts/config --disable SYSTEM_REVOCATION_KEYS
    scripts/config --enable MLX4_CORE
    scripts/config --enable MLX5_CORE
    scripts/config --disable CONFIG_DEBUG_INFO_BTF
    yes "" | make -j \$(nproc)
    yes "" | make modules_install
    yes "" | make install
"