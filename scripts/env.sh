#!/bin/bash
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CUR_DIR" ] || { echo "FATAL: no current dir ?";  exit 1; }

for f in $CUR_DIR/libs/*; do source $f; done

configfile=./config/cluster.yaml


if [[ '' = $1 ]]; then
    local_cluster
else
    local_cluster $1
fi
