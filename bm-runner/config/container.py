# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT

from typing import Optional
from config.list import ListConfig
import docker
import docker.errors
import sys
from utils.logger import bm_log, LogType


# Example configuration:
# "containers": {
#   "container_list": {"values": [{"min": 1, "step": 1, "max": 3}]}
# 	"core_count": 3,
# 	"name": "Container",
# 	"image": "ubuntu:latest",
# },
class ContainersConfig(dict):
    CONFIG_KEY: str = "containers"

    def __init__(
        self,
        container_list: ListConfig = ListConfig(values=[[1]]),
        core_affinity_offsets: Optional[ListConfig] = None,
        core_count: int = 1,
        name: str = "",
        image: str = "hub.oepkgs.net/openeuler/openeuler",
        port: Optional[int] = None,
    ):
        """
        ContainersConfig represents the configuration for multiple containers.
        Represented as a JSON object.
        Parameters
        ----------
        container_list: ListConfig = {"values": [[1]]}
            Specifies the number of containers to run.
        core_affinity_offsets: Optional[ListConfig] = core_count * [0, 1, 2, 3, ...]
            Specifies the cores that should be assigned to the containers.
            Note that the assignment of cores happens in ascending order by default.
        core_count: int
            Number of cores to assign to each container.
        name: str
            The base name of the container.
        image: str
            The docker image name to use.
        port: Optional[int]
            The starting port number to use for the first container.
            Subsequent containers will use incremented port numbers.
            This configuration is relevant for networking benchmarks.
        -
        """
        super().__init__(image=image, name=name, core_count=core_count, port=port)
        self.container_list = ListConfig.from_dict(container_list).get_list()
        self.core_count = core_count
        bm_log(f"Container list: {self.container_list}")
        self.core_affinity_offsets = (
            ListConfig.from_dict(core_affinity_offsets).get_list()
            if core_affinity_offsets is not None
            else [core_count * i for i in range(0, self.container_list[-1])]
        )
        bm_log(f"Container aff list: {self.core_affinity_offsets}")
        self.image = image
        self.name = name
        self.port = port
        self.__ensure_img_exists()

    def get_container_cnt_list(self) -> list[int]:
        return self.container_list

    def get_core_affinity_offset_list(self) -> list[int]:
        return self.core_affinity_offsets

    def __pull_image(self):
        client = docker.from_env()
        bm_log(f"Docker image {self.image} does not exist. Pulling it now...\n", LogType.INFO)
        try:
            client.images.pull(self.image)
        except Exception as e:
            bm_log(f"Failed to pull image {self.image} with error {str(e)}", LogType.FATAL)
            sys.exit(1)

    def __ensure_img_exists(self):
        client = docker.from_env()
        try:
            client.images.get(self.image)
        except docker.errors.ImageNotFound:
            self.__pull_image()
