#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT
set -e
DIR=bm-runner

echo "Running ty"
ty check --venv ./venv ./${DIR}

echo "Running ruff"
ruff check ${DIR} --fix

echo "Running formatter black"
black -l 100 ${DIR}
