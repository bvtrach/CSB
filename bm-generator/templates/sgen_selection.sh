#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


 : ${DIR_IN:="../../bench/targets/syz"}
 : ${SEL_NUM:="100"}
 : ${SEL_SKIP:="0"}

# BLACKLIST="connect recvfrom read accept execve ppoll pread64 readlinkat"
BLACKLIST="connect recvfrom accept execve ppoll"

all=`find "${DIR_IN}" -type f -name 'min_*.h' -print0 | xargs -0 wc -l  | grep -v '^[ ]\+[0-9]\+[ ]\+total$' | sort -rn | sed 's/^[ 0-9]* //'  | tr '\n' ' '`

remain=""

num_selected=0
num_skipped=0

for header in ${all}; do
    if [[ ${num_skipped} -lt ${SEL_SKIP} ]]; then
        num_skipped=$((${num_skipped} + 1))
        continue
    fi
    failed=0
    for black in ${BLACKLIST}; do
        failed=$(($failed + `grep __NR_${black} ${header} | wc -l`))
        if [[ ${failed} -gt 0 ]]; then
            break
        fi
    done
    if [[ $failed -eq 0 ]]; then
        num_selected=$((${num_selected}+1))
        if [ "${remain}" == "" ]; then
            remain="${header}"
        else
            remain="${remain} ${header}"
        fi
    fi
    if [[ ${num_selected} -ge ${SEL_NUM} ]]; then
        break
    fi
done

echo "${remain}"
