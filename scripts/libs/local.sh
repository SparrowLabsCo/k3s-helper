#!/bin/bash

local_cluster() {
    #export K3D_FIX_CGROUPV2=1 ; 
    log_stmt "What is your environment name?"
    read -r cluster_name 
    info_pause_exec "Proceed with local enviroment named ${On_Cyan}$cluster_name${Off}?" "k3d cluster create $cluster_name --config $configfile"
    kubectl config use-context k3d-$cluster_name
}

local_destroy() {
    k3d cluster list
    log_stmt "What environment do you want to destroy?"
    read -r cluster_name
    info_pause_exec_options "Destroy environment named ${On_Cyan}$cluster_name${Off}?" "k3d cluster delete $cluster_name"
}