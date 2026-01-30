#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

awk -F: '/average:/ { printf "average=%s;\n", $2}'
