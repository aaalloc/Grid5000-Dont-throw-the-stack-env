#!/bin/bash


function linux-tools-from-apt {
    apt install -y linux-headers-$(uname -r) linux-image-$(uname -r) linux-tools-$(uname -r)
}

function linux-tools-from-repo {
    # linux code is situated at /home/work
    # in this context the kernel version is 5.15.79, so the folder is linux-5.15.79
    make -C /home/work/linux-5.15.79/tools/perf -j $(nproc)
    make -C /home/work/linux-5.15.79/tools/perf install
    # cp /home/work/linux-5.15.79/tools/perf /usr/lib
    echo "Installed perf at /usr/bin/perf"

    make -C /home/work/linux-5.15.79/tools/power/cpupower -j $(nproc)
    make -C /home/work/linux-5.15.79/tools/power/cpupower install
    # cp -fpR /home/work/linux-5.15.79/tools/power/cpupower/libcpupower.so* /usr/lib
    echo "Installed cpupower at /usr/bin/cpupower"

    make -C /home/work/linux-5.15.79/tools/power/x86/x86_energy_perf_policy -j $(nproc)
    make -C /home/work/linux-5.15.79/tools/power/x86/x86_energy_perf_policy install
    echo "Installed x86_energy_perf_policy at /usr/bin/x86_energy_perf_policy"
}

KERNEL_NAME=$(uname -r)
if [[ $KERNEL_NAME == *"generic"* ]]; then
    linux-tools-from-apt
else
    linux-tools-from-repo
fi
