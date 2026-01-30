#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

set -ex

nic="$1"
core_set="$2"
pid="$3"
name="$4"
ip="$5"
netmask="$6"

ip link set ${nic} netns /proc/${pid}/ns/net
touch "/var/run/netns/${name}"
mount --bind /proc/${pid}/ns/net "/var/run/netns/${name}"

ip netns exec "${name}" "$(dirname $0)/configure-nic-in-netns.sh" ${nic} ${core_set} ${ip} ${netmask}
