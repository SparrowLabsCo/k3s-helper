#!/bin/bash
prep() {
    echo "Installing for $OS/$ARCH"
    
    warn "Please login to Docker to remove rate limits"
    docker login

    section "Pull container images"
    docker pull "rancher/k3s:v$K3S_VERSION-k3s1"
    docker pull rancher/k3d-proxy:$K3D_VERSION
    docker pull rancher/k3d-tools:$K3D_VERSION
    docker pull python:3.7-slim

    check
}

check() {
    section "Check tools"
    if (! check_command k3d); then
       install_k3d
    fi
    if (! check_command kubectl); then
       #install_kubectl
       info "We could not find kubectl installed.  Please read more on installing kubectl - https://kubernetes.io/docs/tasks/tools/"
    fi
    if (! check_command helm); then
       install_helm
    fi
    #check_command argicd
    if (! check_command argocd); then
       install_argocd_cli
    fi
    if (! check_command flux); then
       install_flux
    fi
}