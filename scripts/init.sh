#!/bin/bash

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CUR_DIR" ] || { echo "FATAL: no current dir ?";  exit 1; }

for f in $CUR_DIR/libs/*; do source $f; done

section "Pull images..."
docker pull rancher/k3s:v1.22.2-k3s1
docker pull rancher/k3d-proxy:5.0.0
docker pull rancher/k3d-tools:5.0.0
docker pull python:3.7-slim
