#!/bin/sh
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


PREFIX=/usr/local/
VER=1.4.2
URL=https://github.com/open-s4c/tmplr/archive/refs/tags/v$VER.tar.gz
DIR=tmplr-$VER
TAR=$DIR.tar.gz

curl -Lo $TAR "$URL"
tar zxf $TAR
sudo make -C $DIR clean all install PREFIX=$PREFIX
rm $TAR
rm -rf $DIR
