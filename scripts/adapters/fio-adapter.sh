#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

awk '/READ:/ {sub(/MiB\/s/,"",$2); printf "read_MiB_%s;", $2}'
