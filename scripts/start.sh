#!/bin/bash

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CUR_DIR" ] || { echo "FATAL: no current dir ?";  exit 1; }

for f in $CUR_DIR/libs/*; do source $f; done

configfile=./config/cluster.yaml

warn "Please login to Docker to remove rate limits"
docker login

info_pause_exec "Creating cluster with name \"$1\"" "k3d cluster create $1 --config $configfile"

#export K3D_FIX_CGROUPV2=1 ; 
kubectl config use-context k3d-$1