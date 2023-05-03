#!/bin/bash

install_spark() {
    helm repo add spark-operator https://googlecloudplatform.github.io/spark-on-k8s-operator
    helm install spark spark-operator/spark-operator --namespace spark-operator --create-namespace
}

install_flux() {
    info "Installing FluxCD"
    curl -s https://fluxcd.io/install.sh | sudo bash
    flux --version
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
   
    tld="$TLD.local"
    env_tld="$1.${tld}"
    argo_url="argocd.$env_tld"
    argo_grpc_url="grpc-argocd.$env_tld"

    info "Adding host information for ArgoCD"
    add-host  127.0.0.1 $argo_url
    add-host  127.0.0.1 $grpc_url

    sed "s|&argoHTTP|$argo_url|g; s|&argoGRPC|$argo_grpc_url|g;" $(pwd)/manifests/templates/argo-ingress.tmpl > $(pwd)/manifests/templates/argo-ingress.yaml
    kubectl apply -n argocd -f $(pwd)/manifests/templates/argo-ingress.yaml

}

connect_to_argo(){
    
    if (proceed_or_no "Do you want to connect to ArgoCD now?"); then
     
        if [[ 'darwin' = $OS ]]; then
            open https://$argo_url:$HTTPS_INGRESS_PORT
        elif [[ 'linux' = $OS ]]; then
            xdg-open https://$argo_url:$HTTPS_INGRESS_PORT
        fi

    fi
}

install_flamingo(){
    kubectl apply -n argocd -f `pwd`/manifests/templates/flamingo.yaml
    info 'Wait for Flamingo to finish installing...'
    kubectl -n argocd rollout status deployment.apps/argocd-server
}

install_metal_lb(){
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.3/manifests/namespace.yaml
    kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.3/manifests/metallb.yaml

    cidr_block=$(docker network inspect k3d-$1 | jq '.[0].IPAM.Config[0].Subnet' | tr -d '"')
    base_addr=${cidr_block%???}
    first_addr=$(echo $base_addr | awk -F'.' '{print $1,$2,$3,240}' OFS='.')
    range=$first_addr/29

    info $range

    sed "s|&range|$range|g;" "$(pwd)/config/metal_lb.tmpl" | kubectl apply -f -

}