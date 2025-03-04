#!/bin/bash

rmmod mlx4_ib
rmmod mlx4_core
insmod /home/work/connectx3-driver/mlx4_core.ko
insmod /home/work/connectx3-driver/mlx4_en.ko
