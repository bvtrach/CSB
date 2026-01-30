#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

set -e

BM_DIR=bm-runner

### Configure the env
if test -d venv; then
    echo "benchmark environment already configured"
else
    ./scripts/configure.sh
fi
. ./venv/bin/activate

cd ${BM_DIR}
python3 document.py
