#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

awk '/stress-ng: metrc:/ {
    count++;
    if (count == 3) {
        printf "stressor=%s;ops=%s;real_time=%s;usr_time=%s;sys_time=%s;throughput_real=%s;throughput_cpus=%s;cpu_percent=%s;rss_max=%s;\n",
               $4, $5, $6, $7, $8, $9, $10, $11, $12
    }
}'
