#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT
set -e
export CSB_RESULTS_GROUP="echo"
source helper/bm-generator-lib.sh
STRACE_LOG="echo_strace.log"
APP="echo"
../scripts/plugins/collect_strace.sh ${STRACE_LOG} ${APP}
echo "STEP#0: Initializing ..."
./00_init.sh
echo "STEP#1: Building ..."
./01_build.sh
echo "STEP#2: Parsing ${STRACE_LOG} ..."
./02_parse.sh ${STRACE_LOG}
echo "STEP#3: Extracting ..."
./03_extract.sh
echo "STEP#4: Reducing ..."
./04_reduce.sh
echo "STEP#5: Filtering with multidiff ..."
./05_multidiff.sh
echo "STEP#6: Preparing ..."
./06_prepare.sh
echo "STEP#7: Generating ..."
./07_generate.sh
echo "STEP#7.5 Reducing test duration"
sed -i -e 's/60,/5,/g' ../config/${CSB_RESULTS_GROUP}/*.json
echo "STEP#8: Selecting benchmarks using flamegraph-diff ..."
./08_select.sh
