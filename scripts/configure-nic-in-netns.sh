#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

set -ex

nic="$1"
core_set="$2"
ip="$3"
netmask="$4"

# For each interrupt number of the device...
for irq in /sys/class/net/${nic}/device/msi_irqs/*; do
	# ... set the affinity to the provided core list.
        echo "$core_set" > /proc/irq/$(basename $irq)/smp_affinity_list
done

# Add IP address to the NIC
ip addr add dev ${nic} ${ip}/${netmask}
ip link set dev ${nic} up
