# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

from config.benchmark import MonitorType
from monitors.sys_stats import SystemStats
from monitors.redis_bench import RedisStats
from monitors.perf import FlameGraph
from monitors.sarnet import SarNetStats
from monitors.monitor import Monitor
from utils.logger import bm_log, LogType
import sys


class MonitorFactory:
    @staticmethod
    def create(monitor_type: MonitorType, results_dir, args) -> Monitor:
        match monitor_type:
            case MonitorType.MPSTAT:
                return SystemStats(output_dir=results_dir, args=args)
            case MonitorType.PERF:
                return FlameGraph(output_dir=results_dir, args=args)
            case MonitorType.REDIS_BENCHMARK:
                return RedisStats(output_dir=results_dir, args=args)
            case MonitorType.SAR_NET:
                return SarNetStats(output_dir=results_dir, args=args)
            case _:
                bm_log(f"Unsupported monitor type {monitor_type}", LogType.FATAL)
                sys.exit(1)
