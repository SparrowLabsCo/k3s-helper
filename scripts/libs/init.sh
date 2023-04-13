#!/bin/bash
prep() {
    echo "Installing for $ARCH"
    
    warn "Please login to Docker to remove rate limits"
    docker login

    section "Pull container images"
    docker pull "rancher/k3s:v$K3S_VERSION-k3s1"
    docker pull rancher/k3d-proxy:5.0.0
    docker pull rancher/k3d-tools:5.0.0
    docker pull python:3.7-slim

    section "Check tools"
    check_command kubectl
    check_command helm
    check_command terraform
    if (! check_command argocd); then
       install_argocd_cli
    fi
}
