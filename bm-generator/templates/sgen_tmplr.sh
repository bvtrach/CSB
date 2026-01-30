#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


 : ${DIR_OUT_H:="../../bench/targets"}
 : ${DIR_OUT_J:="../../config"}
 : ${DIR_IN:="../../bench/targets/syz"}
 : ${GEN_ALL_SINGLE:=1}

TMPLR_ARGS="-l 4096"

if ! command -v tmplr >/dev/null 2>&1; then
    echo "tmplr is not installed run tmplr.sh to install it."
    exit 1
fi

HEAD_SWITCH_IN="syz_switch.h.in"
HEAD_SWITCH_OUT="${DIR_OUT_H}/syz_switch.h"

JSON_SWITCH_IN="syz_switch.json.in"
JSON_SWITCH_OUT="${DIR_OUT_J}/syz_switch.json"

HEAD_THREAD_IN="syz_thread.h.in"
HEAD_THREAD_OUT="${DIR_OUT_H}/syz_thread.h"

JSON_THREAD_IN="syz_thread.json.in"
JSON_THREAD_OUT="${DIR_OUT_J}/syz_thread.json"

HEAD_PROCS_IN="syz_procs.h.in"
HEAD_PROCS_OUT="${DIR_OUT_H}/syz_procs.h"

JSON_PROCS_IN="syz_procs.json.in"
JSON_PROCS_OUT="${DIR_OUT_J}/syz_procs.json"

JSON_BM_IN="syz_bm.json.in"
JSON_BM_OUT="${DIR_OUT_J}/syz_bm.json"

HEAD_SINGLE_IN="syz_single.h.in"
JSON_SINGLE_IN="syz_single.json.in"

TMP_HEAD_IN="head.tmp"
TMP_JSON_IN="json.tmp"

FILES_ARG="$@"
FILES_ARG_NUM=$#

if [ ${FILES_ARG_NUM} -eq 0 ]; then
    export DIR_IN="${DIR_IN}"
    # use regex from input for this instead of list of files
    FILES_CONV_SEL="`./sgen_selection.sh`"
else
    FILES_CONV_SEL="${FILES_ARG}"
fi

arr=($FILES_CONV_SEL)
FILES_NUM=${#arr[@]}

FILES_CONV_ALL=`find "${DIR_IN}" -type f -name 'min_*.h' -print0 | xargs -0 wc -l  | grep -v '^[ ]\+[0-9]\+[ ]\+total$' | sort -rn | sed 's/^[ 0-9]* //'  | tr '\n' ' '`

if [ ${FILES_NUM} -gt 1024 ]; then
    echo "slected more than 1024 files; only up to 1024 operations per benchmark are supported right now!"
    exit 1
fi

probavg=$((1024 / ${FILES_NUM}))
probend=$(($probavg + (1024 % ${FILES_NUM}) ))

function clearTmpFiles {
    for tmp_file in $@; do
        if [ -f "${tmp_file}" ]; then
            rm "${tmp_file}"
        fi
    done
}


function generateSingleBench {
    PROGNAME="$1"

    S_HEAD_IN="${HEAD_SINGLE_IN}"
    S_JSON_IN="${JSON_SINGLE_IN}"

    S_TMP_HEAD_IN="S_${S_HEAD_IN}.tmp"
    S_TMP_JSON_IN="S_${S_JSON_IN}.tmp"

    clearTmpFiles "${S_TMP_HEAD_IN}" "${S_TMP_JSON_IN}"

    echo "\$_map(CASE_${PROGNAME},0);" >> "${S_TMP_HEAD_IN}"

    cat ${S_HEAD_IN} >> "${S_TMP_HEAD_IN}"
    cat ${S_JSON_IN} >> "${S_TMP_JSON_IN}"

    S_HEAD_OUT="${DIR_OUT_H}/${PROGNAME}.h"
    S_JSON_OUT="${DIR_OUT_J}/${PROGNAME}.json"
    #set -x

    tmplr ${TMPLR_ARGS} -DNCALLS="1" -DNNOPS="1" -DNN="${PROGNAME}" "${S_TMP_HEAD_IN}" > "${S_HEAD_OUT}"
    tmplr ${TMPLR_ARGS} -DPROBAVG="" -DPROBEND="1024" -DBINNAME="${PROGNAME}" "${S_TMP_JSON_IN}" > "${S_JSON_OUT}"

    clearTmpFiles "${S_TMP_HEAD_IN}" "${S_TMP_JSON_IN}"
}

prognames=""
probs=""
lastprog=""
idx=0

clearTmpFiles "${TMP_HEAD_IN}" "${TMP_JSON_IN}"

for filename in ${FILES_CONV_SEL}; do
    progname=`basename "${filename}" .h`
    if [ "${prognames}" == "" ]; then
        prognames="$progname"
        probs="${probavg}"
    else
        prognames="$progname;${prognames}"
        probs="$probavg;${probs}"
    fi
    echo "\$_map(CASE_${progname},${idx});" >> "${TMP_HEAD_IN}"
    idx=$(($idx + 1))
    lastprog="${progname}"
    if [ ${GEN_ALL_SINGLE} -eq 0 ]; then
        generateSingleBench "${progname}"
        echo "Generated $progname"
    fi
done

if [ ${GEN_ALL_SINGLE} -ne 0 ]; then
    for filename in ${FILES_CONV_ALL}; do
        progname=`basename "${filename}" .h`
        generateSingleBench "${progname}"
        echo "Generated $progname"
    done
fi

# Generate SWITCHED version

function generateSwitchBench {
    cat ${HEAD_SWITCH_IN} >> "${TMP_HEAD_IN}"
    cat ${JSON_SWITCH_IN} >> "${TMP_JSON_IN}"
    # set -x

    # remove one from list of probs, so together with the last elemement is is the correct lenght again
    probs="`echo $probs | cut -d ';' -f 2-`"

    tmplr ${TMPLR_ARGS} -DBINNAME="`basename ${JSON_SWITCH_OUT} .json`" -DNCALLS="${FILES_NUM}" -DNNOPS="0" -DNN="${prognames}" "${TMP_HEAD_IN}" > "${HEAD_SWITCH_OUT}"
    tmplr ${TMPLR_ARGS} -DBINNAME="`basename ${JSON_SWITCH_OUT} .json`" -DPROBAVG="${probs}" -DPROBEND="${probend}" "${TMP_JSON_IN}" > "${JSON_SWITCH_OUT}"

    echo "Generated `basename ${JSON_SWITCH_OUT} .json`"

    clearTmpFiles "${TMP_HEAD_IN}" "${TMP_JSON_IN}"
}

# Generate THREADED version

function generateThreadBench {
    cat ${HEAD_THREAD_IN} > "${TMP_HEAD_IN}"
    cat ${JSON_THREAD_IN} > "${TMP_JSON_IN}"
    # set -x

    tmplr ${TMPLR_ARGS} -DBINNAME="`basename ${JSON_THREAD_OUT} .json`" -DNTHREADS="${FILES_NUM}" -DNCALLS="1" -DNNOPS="0" -DNN="${prognames}" "${TMP_HEAD_IN}" > "${HEAD_THREAD_OUT}"
    tmplr ${TMPLR_ARGS} -DBINNAME="`basename ${JSON_THREAD_OUT} .json`" "${TMP_JSON_IN}" > "${JSON_THREAD_OUT}"

    echo "Generated `basename ${JSON_THREAD_OUT} .json`"

    clearTmpFiles "${TMP_HEAD_IN}" "${TMP_JSON_IN}"
}

# Generate PROCESS version

function generateProcessBench {
    cat ${HEAD_PROCS_IN} > "${TMP_HEAD_IN}"
    cat ${JSON_PROCS_IN} > "${TMP_JSON_IN}"
    # set -x

    tmplr ${TMPLR_ARGS} -DBINNAME="`basename ${JSON_PROCS_OUT} .json`" -DNPROCS="${FILES_NUM}" -DNCALLS="1" -DNNOPS="0" -DNN="${prognames}" "${TMP_HEAD_IN}" > "${HEAD_PROCS_OUT}"
    tmplr ${TMPLR_ARGS} -DBINNAME="`basename ${JSON_PROCS_OUT} .json`" "${TMP_JSON_IN}" > "${JSON_PROCS_OUT}"

    echo "Generated `basename ${JSON_PROCS_OUT} .json`"

    clearTmpFiles "${TMP_HEAD_IN}" "${TMP_JSON_IN}"
}

# Generate JSON Apps version

function generateMultiAppBench {
    cat ${JSON_BM_IN} > "${TMP_JSON_IN}"
    tmplr ${TMPLR_ARGS} -DNN="${prognames}" -DNPROCS="${FILES_NUM}" "${TMP_JSON_IN}" > "${JSON_BM_OUT}"
    echo "Generated `basename ${JSON_BM_OUT} .json`"
    clearTmpFiles "${TMP_JSON_IN}"
}

# generateSwitchBench
# generateThreadBench
# generateProcessBench
generateMultiAppBench
