#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


if [ $# != 1 ]; then
  echo "Usage: $0 </path/to/c/file>"
  exit 1
fi

CFILE="$1"

CC=clang

${CC} -g -O0 "${CFILE}" -o "${CFILE}".out
