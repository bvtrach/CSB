#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


 : ${DIR_PROG:="./deserialized"}
 : ${CONTAINS:=""}
 : ${MINCALLS:=4}

FILE_OUT="progs.stat"

files=`find "${DIR_PROG}" -type f -name '*'"${CONTAINS}"'*.prog'`

for file in ${files}; do
  numcalls=`wc -l "${file}" | cut -d ' ' -f 1`
  if [ ${numcalls} -lt ${MINCALLS} ]; then
    continue
  fi
  echo $file | tee -a "${FILE_OUT}"
  cat ${file} | sed 's/^r[0-9]\+ = //' | cut -d '(' -f 1 | sort | uniq -c | sort -rn >> "${FILE_OUT}"
done

echo "Statistics can be found in ${FILE_OUT}"
