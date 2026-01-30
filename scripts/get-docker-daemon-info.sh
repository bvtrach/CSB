#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

set -e

if [ -z "$1" ];
then
        echo "Error: result directory not provided, skipping docker-daemon config"
        exit 1
fi

mkdir -p "$1"

if command -v containerd >/dev/null 2>/dev/null; then
    containerd config dump > "$1"/containerd.txt 2>&1 || true
fi

if command -v dockerd >/dev/null 2>/dev/null; then
    echo -e "# Default Setup:\n" > "$1"/dockerd.txt
    dockerd --help | grep "(default" | sed 's/.*--\(.*\)./\1/g' | awk '{print $1"="$NF}' >> "$1"/dockerd.txt
fi

if [ -f /etc/docker/daemon.json ]; then
    echo -e "\n# Non-default setup:\n" >> "$1"/dockerd.txt
    cat /etc/docker/daemon.json | jq -r 'to_entries[] | "\(.key)=\(.value)"' >> "$1"/dockerd.txt
fi

echo -e "\n# Command-line parameters:\n" >> "$1"/dockerd.txt
ps ax | grep dockerd | grep bin | awk '{$1=$2=$3=$4=$5=""; print $0}' >> "$1"/dockerd.txt
