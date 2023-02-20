#!/bin/bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CURR_DIR" ] || { echo "FATAL: no current dir ?";  exit 1; }

for f in $CURR_DIR/libs/*; do source $f; done

configfile=./config/cluster.yaml

info_pause_exec_options "Destroy cluster $1?" "k3d cluster delete $1"