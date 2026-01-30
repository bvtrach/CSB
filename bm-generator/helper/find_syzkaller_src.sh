#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


DIR_BUILD=`find . -type d -name CMakeFiles |        \
     awk 'BEGIN { OFS="\t" }{print length,$0}'  |   \
     sort -n |                                      \
     head -1 |                                      \
     cut -f 2 |                                     \
     sed 's/CMakeFiles$//'`

SYZ_SRC="${DIR_BUILD}/_deps/syzkaller-src"

if [ -d "${SYZ_SRC}" ]; then
     echo "${SYZ_SRC}"
fi
