#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


 : ${ROCKSDB_DIR:="bm-external/rocksdb"}

rocksdb_exe="${ROCKSDB_DIR}/db_bench"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <command to run>"
  exit 1
fi

if [ ! -f "${rocksdb_exe}" ]; then
  echo "RocksDB executable db_bench not found in directory ${ROCKSDB_DIR}."
  echo "Check if RocksDB has been succesfully installed, or alter the directory variable ROCKSDB_DIR."
  exit 1
fi

binary="$1"
threads="$2"
duration="$3"
res_dir="$4"
index="$5"
num=1000000

$rocksdb_exe --threads=${threads} --num=${num} --db=${res_dir}/${index}-rocksdb --benchmarks=fillseq >/dev/null 2>/dev/null
$rocksdb_exe --threads=${threads} --duration=${duration} --use_existing_db=1 --db=${res_dir}/${index}-rocksdb --benchmarks=readrandom,multireadrandom,seekrandom,overwrite,readwhilewriting,seekrandomwhilewriting,compact
