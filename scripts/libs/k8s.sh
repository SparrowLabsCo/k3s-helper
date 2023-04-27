#!/bin/bash

wait_for_job(){
    info "Waiting for job $1 to complete"
    kubectl -n $2 wait --for=condition=complete --timeout=600s job.batch/$1
}

wait_for_deployment(){
    info "Waiting for deployment of $1 to complete"
    kubectl rollout status deployment $1 -n $2
    #kubectl -n $2 wait --for=condition=Available=True --timeout=600s deployment.apps/$1
}

wait_for_daemonset(){
    info "Waiting for deployment of $1 to complete"
    kubectl rollout status $(kubectl -n $2 get ds -l $1 -o name) -n $2 --timeout=600s
}

check_cluster_exists(){
    info "Checking if cluster already exists."
    hasCluster=$(k3d cluster list | grep -w $1 | cut -d " " -f 1)
    if [ "$hasCluster" == "$1" ]; then
        error "Cluster with name $1 already exist."
        exit 100
    fi
}