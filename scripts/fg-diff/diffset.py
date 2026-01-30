#!/usr/bin/python3
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

import argparse
import pandas as pd
import pathlib

def process(result_file, cutoff):
    d = pd.read_csv(result_file, header=None, comment="#", engine="python", on_bad_lines="error")
    s = set(d[0])
    for i,r in d.sort_values(by=[0, 1]).iterrows():
        if r[0] != r[1] and r[0] in s and r[2] < cutoff:
            s.discard(r[1])
    return s

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Filter benchmarks based on the similarity of the flame graphs")
    parser.add_argument(
        "--cutoff",
        help="The benchmarks with maximum stack difference below this percentage will be considered the same.",
        type=float
    )
    parser.add_argument(
        "--input",
        help="Path to the input csv file.",
        type=pathlib.Path,
        required=True,
    )
    (args, unknown_args) = parser.parse_known_args()
    s = process(args.input, args.cutoff)
    for i in sorted(s):
        print(i.removesuffix(".html.stacks"))
