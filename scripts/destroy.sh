#!/bin/bash
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CUR_DIR" ] || { echo "FATAL: no current dir ?";  exit 1; }

for f in $CUR_DIR/libs/*; do source $f; done

configfile=./config/cluster.yaml

if [[ '' = $1 ]]; then
    local_destroy
else
    info_pause_exec_options "Are you sure? This action will destroy the environment named ${On_Cyan}$1${Off}?" "k3d cluster delete $1"
fi