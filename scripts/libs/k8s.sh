#!/bin/bash

wait_for_job(){
    info "Waiting for job $1 to complete"
    kubectl -n $2 wait --for=condition=complete --timeout=600s job.batch/$1
}

wait_for_deployment(){
    info "Waiting for deployment $1 to complete"
    kubectl -n $2 wait --for=condition=Available=True --timeout=600s deployment.apps/$1
}