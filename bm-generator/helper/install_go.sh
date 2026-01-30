#!/bin/bash
# Copyright (C) Huawei Technologies Co., Ltd. 2026. All rights reserved.
# SPDX-License-Identifier: MIT


PREFIX=/usr/local
GO_VER="1.25.5"

ARCH_UNAME="`uname -m`"
ARCH_GO="amd64"

if [ -d "${PREFIX}/go" ]; then
  echo "Found go directory"
  echo "  ${PREFIX}/go"
  if [ -f "${PREFIX}/go/bin/go" ]; then
    echo "It has: `${PREFIX}/go/bin/go version`"
    exit 1
  else
    echo "However, cound not find go executable \""${PREFIX}/go/bin/go"\""
    echo "If this is a broken installation, you may want to remove \""${PREFIX}/go\""
    echo "  sudo rm -rf \""${PREFIX}/go\""
    exit 1
  fi
fi

case "${ARCH_UNAME}" in
"arm64" | "aarch64")
    ARCH_GO="arm64"
    ;;
esac

TAR="go-${GO_VER}.tar.gz"

URL="https://go.dev/dl/go${GO_VER}.linux-${ARCH_GO}.tar.gz"

curl -Lo "${TAR}" "${URL}"

echo "Using sudo to execute:"
echo "  tar -C \"${PREFIX}/\" -xzf \"$TAR\""
sudo tar -C "${PREFIX}/" -xzf "$TAR"

echo "Add ${PREFIX}/go/bin to \$PATH, possibly like so:"
echo "  echo \"export PATH=\$PATH:${PREFIX}/go/bin\" >> $HOME/.bashrc"
echo "Restart terminal session"