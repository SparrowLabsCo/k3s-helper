#!/bin/bash

install_spark() {
    helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
    helm install spark spark-operator/spark-operator --namespace spark-operator --create-namespace
}

install_k3d(){
    echo "Installing K3D"
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v$K3D_VERSION bash
}

install_argocd_cli(){
    echo "Installing ArgoCD CLI v$ARGOCD_VERSION"
    url="https://github.com/argoproj/argo-cd/releases/download/v$ARGOCD_VERSION/argocd-$OS-$ARCH"
    echo "Pulling from $url"
    sudo curl -sSL -o /usr/local/bin/argocd $url
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
            open http://localhost:8888
        elif [[ 'linux' = $OS ]]; then
            xdg-open http://localhost:8888
        fi

        kubectl  -n argocd port-forward svc/argocd-server 8888:443
    fi
}