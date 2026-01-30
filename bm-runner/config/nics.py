# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

from typing import Optional
from config.list import ListConfig
from utils.logger import bm_log


class ContainerNicConfig(dict):
    def __init__(
        self,
        nic: str,
        ip: str,
        netmask: int,
        core_affinity_offset: Optional[int] = None,
    ):
        super().__init__(nic=nic, ip=ip, netmask=netmask)
        self.nic = nic
        self.ip = ip
        self.netmask = netmask
        self.core_affinity_offset = core_affinity_offset


class NicsConfig(dict):
    CONFIG_KEY: str = "nics"

    def __init__(
        self,
        nic_format: str,
        ips: ListConfig,
        netmask: int,
        core_affinity_offsets: Optional[ListConfig] = None,
    ):
        """
        NicsConfig configures the assignment of Network Interface Cards (NICs) or their Virtual
        Functions (VFs) to containers. Represented as a JSON object.
        Parameters:
        -----------
        nic_format: str
            A formatting string to get a NIC name for a containers. It supports a single formatting
            argument `{i}` -- the index of the container in a benchmarking run.
        ips: ListConfig
            Specifies the list of IP addresses that are assigned to a container sequentially in each
            run.
        netmask: int
            The IPv4 netmask to specify along with the IP address.
        core_affinity_offsets: Optional[ListConfig]
            Specifies the cores that should be assigned to handle the NIC/VF IRQs.
            Note that the assignment of cores will happen in ascending order.
        -
        """
        super().__init__(nic_format=nic_format, ips=ips, netmask=netmask)
        self.nic_format = nic_format
        self.ips = ListConfig.from_dict(ips).get_list()
        self.core_affinity_offsets = (
            ListConfig.from_dict(core_affinity_offsets).get_list()
            if core_affinity_offsets is not None
            else None
        )
        self.netmask = netmask

    def get_cfg(self, i: int):
        nic = self.nic_format.format(i=i)
        bm_log(f"nic: {nic}")
        ip = self.ips[i]
        return ContainerNicConfig(
            nic,
            ip,
            self.netmask,
            self.core_affinity_offsets[i] if self.core_affinity_offsets is not None else None,
        )
