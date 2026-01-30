#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


JOBS=32

 : ${DIR_PROG:="./deserialized"}

find "${DIR_PROG}" -type f -name '*.prog' -print0 | xargs -0 -n 1 -P ${JOBS} ./HULK_scripts/prog2c.sh
