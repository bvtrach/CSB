#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT
set -e

CONFIG="$1"

if [ -z "$CONFIG" ]; then
    exit 1
fi
TITLE=$(basename "$CONFIG" .json)

## this script is to be embedded in other scripts
HOSTNAME=$(hostname)

# Infer the important dirs
SCRIPT_DIR=$( cd -- "$( dirname -- "$0" )" &> /dev/null && pwd)
export FLAMEGRAPH="${SCRIPT_DIR}/../../deps/FlameGraph"
export SHE_HULK_ADAPTERS="${SCRIPT_DIR}/../../scripts/adapters"
BM_DIR=bm-runner

info() {
    echo "[run.sh] $1"
}

### Configure the env
if test -d venv; then
    info "benchmark environment already configured"
else
    info "configuring benchmark environment"
    ./scripts/configure.sh
fi
. ./venv/bin/activate

### change dir to bm-runner
cd ${BM_DIR}

info "running $TITLE on $CONFIG"
python3 main.py --title "$TITLE" --config "$CONFIG"
