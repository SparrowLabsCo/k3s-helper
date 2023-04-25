#!/bin/bash

install_spark() {
    helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
    helm install spark spark-operator/spark-operator --namespace spark-operator --create-namespace
}

install_k3d(){
    info "Installing K3D"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    k3d --help
}

install_helm(){
    info "Installing Helm"
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    helm version
    rm ./get_helm.sh
}

install_argocd_cli(){
    info "Installing ArgoCD CLI v$ARGOCD_VERSION"
    url="https://github.com/argoproj/argo-cd/releases/download/v$ARGOCD_VERSION/argocd-$OS-$ARCH"
    info "Pulling from $url"
    sudo curl -fsSL -o /usr/local/bin/argocd $url
    sudo chmod +x /usr/local/bin/argocd
    argocd version --client
}

install_argocd(){
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v$ARGOCD_VERSION/manifests/install.yaml
    info 'Wait for ArgoCD to finish installing...'
    kubectl -n argocd rollout status deployment.apps/argocd-server
    initial_pass=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d )
    info "Here's your password to login to ArgoCD: $initial_pass"

    if (proceed_or_no "Do you want to connect to ArgoCD now?"); then
     
        if [[ 'darwin' = $OS ]]; then
            open https://localhost:8888
        elif [[ 'linux' = $OS ]]; then
            xdg-open https://localhost:8888
        fi

        kubectl  -n argocd port-forward svc/argocd-server 8888:443
    fi
}