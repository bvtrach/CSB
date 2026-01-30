#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

set -e

if [ -z "$1" ];
then
        echo "Error: result directory not provided, skipping docker-container config"
        exit 1
fi

if [ -z "$2" ];
then
        echo "Error: docker container not provided, skipping docker-container config"
        exit 1
fi

mkdir -p "$1"

docker inspect $2 > "$1"/container-"$2".txt

ignore="Id ID LogPath Created StartedAt FinishedAt ResolvConfPath HostnamePath HostsPath LowerDir MergedDir UpperDir WorkDir Hostname SandboxID SandboxKey"
for key in $ignore
do
        sed -i "s/$key\":.*/$key\": CONTAINER-SPECIFIC/g" "$1"/container-"$2".txt
done
