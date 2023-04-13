#!/bin/bash

install_spark() {
    helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
    helm install spark spark-operator/spark-operator --namespace spark-operator --create-namespace
}

install_argocd_cli(){
    echo "Installing ArgoCD CLI v$ARGOCD_VERSION"
    url="https://github.com/argoproj/argo-cd/releases/download/v$ARGOCD_VERSION/argocd-$OS-$ARCH"
    echo "Pulling from $url"
    sudo curl -sSL -o /usr/local/bin/argocd $url
    sudo chmod +x /usr/local/bin/argocd
    argocd version --client
}