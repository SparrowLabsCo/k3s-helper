#!/bin/bash

wait_for_job(){
     kubectl -n $2 wait --for=condition=complete --timeout=600s job.batch/$1
}

wait_for_deployment(){
    kubectl -n $2 wait --for=condition=Available=True --timeout=600s deployment.apps/$1
}