#!/bin/bash
prep() {
    echo "Installing for $ARCH"
    
    warn "Please login to Docker to remove rate limits"
    docker login

    section "Pull container images"
    docker pull "rancher/k3s:v$K8S_VERSION-k3s1"
    docker pull rancher/k3d-proxy:5.0.0
    docker pull rancher/k3d-tools:5.0.0
    docker pull python:3.7-slim

    section "Check tools"
    check_command kubectl
    check_command helm
    check_command terraform
    if (! check_command argocd); then
        echo "Installing ArgoCD CLI v$ARGOCD_VERSION"
        URL="https://github.com/argoproj/argo-cd/releases/download/v$ARGOCD_VERSION/argocd-$OS-$ARCH"
        echo "Pulling from $URL"
        sudo curl -sSL -o /usr/local/bin/argocd $URL
        sudo chmod +x /usr/local/bin/argocd
        argocd version --client
    fi
}
