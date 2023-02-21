#!/bin/bash

CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
[ -d "$CUR_DIR" ] || { echo "FATAL: no current dir ?";  exit 1; }

for f in $CUR_DIR/libs/*; do source $f; done

configfile=./config/cluster.yaml

mainmenu() {
    echo -ne "
$(magentaprint 'Start options:')
$(greenprint '1)') Prep Machine
$(greenprint '2)') Start a Local Environment
$(greenprint '3)') Destroy a Local Environment
$(redprint '0)') Exit
""
Choose an option:  "
    read -r ans
    case $ans in
    1)
        prep
        mainmenu
        ;;
    2)
        local_cluster
        mainmenu
        ;;
    3)
        local_destroy
        ;;
    0)
        ok
        ;;
    *)
        retry
        mainmenu
        ;;
    esac
}

mainmenu