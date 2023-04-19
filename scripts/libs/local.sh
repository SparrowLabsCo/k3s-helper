#!/bin/bash

local_cluster() {
    #export K3D_FIX_CGROUPV2=1 ; 
    k3s_image="rancher/k3s:v$K3S_VERSION-k3s1"
    sed -i '' "s|K3S_VERSION_REPL|$k3s_image|g" "$(pwd)/config/cluster.yaml"
    sed -i '' "s|HTTP_PORT_REPL|$HTTP_INGRESS_PORT|g" "$(pwd)/config/cluster.yaml"
    sed -i '' "s|HTTPS_PORT_REPL|$HTTPS_INGRESS_PORT|g" "$(pwd)/config/cluster.yaml"
    sed -i '' "s|API_SERVER_PORT_REPL|$API_SERVER_PORT|g" "$(pwd)/config/cluster.yaml"
    
    echo "Installing $k3s_image"
    log_stmt "What is your environment name?"
    read -r cluster_name 
   
    info "Deploying local cluster named $cluster_name, with network ingress ports: $HTTP_INGRESS_PORT, $HTTPS_INGRESS_PORT"
    sed -i '' "s|CLUSTER_NAME_REPL|k3d-env-$cluster_name|g" "$(pwd)/config/cluster.yaml"
    ingressmenu $cluster_name $HTTP_INGRESS_PORT
}

switch_context(){
    if (k3d cluster list | grep -q "$1"); then
        kubectl config use-context k3d-$1 
    fi
}

local_destroy() {
    k3d cluster list
    log_stmt "Which environment do you want to destroy?"
    read -r cluster_name
    info_pause_exec_options "Destroy environment named ${On_Cyan}$cluster_name${Off}?" "k3d cluster delete $cluster_name"
}

default_ingress_options(){
    info_pause_exec_options "Proceed with local environment named ${On_Cyan} $1 ${Off}?" "k3d cluster create $1 --config $configfile"
    switch_context $1
}

nginx_ingress_options(){
    info_pause_exec_options "Proceed with local environment named ${On_Cyan} $1 ${Off}, using ${On_Cyan} NGINX ${Off} ingress?" "k3d cluster create $1 --k3s-arg='--disable=traefik@server:0' --volume '$(pwd)/manifests/nginx-ingress.yaml:/var/lib/rancher/k3s/server/manifests/nginx-ingress.yaml' --config $configfile"
    info "Cluster created!  Waiting for NGINX to complete.  This can take up to 5 minutes."
    switch_context $1
    kubectl -n kube-system wait --for=condition=complete --timeout=600s job.batch/helm-install-ingress-controller-nginx
    kubectl -n kube-system wait --for=condition=Available=True --timeout=600s deployment.apps/ingress-controller-nginx-ingress-nginx-controller
    info "Your cluster ingress is ready.  Trying ingress using port $2."
    curl -i localhost:$2
}

traefik_ingress_options(){
    info_pause_exec_options "Proceed with local environment named ${On_Cyan} $1 ${Off}, using ${On_Cyan} NGINX ${Off} ingress?" "k3d cluster create $1 --k3s-arg='--disable=traefik@server:0' --volume '$(pwd)/manifests/traefik-ingress.yaml:/var/lib/rancher/k3s/server/manifests/traefik-ingress.yaml' --config $configfile"
    switch_context $1
}

ingressmenu() {
    echo -ne "
$(magentaprint 'Select an ingress option:')
$(greenprint '1)') Rancher Default (Traefik v1)
$(greenprint '2)') NGINX
$(greenprint '3)') Traefik v2
$(redprint '0)') Exit
""
Choose an option:  "
    read -r ans
    case $ans in
    1)
        echo ""
        default_ingress_options $1 $2
        ;;
    2)
        echo ""
        nginx_ingress_options $1 $2
        ;;
    3)
        echo ""
        traefik_ingress_options $1 $2
        ;;
    0)
        mainmenu
        ;;
    *)
        retry
        ingressmenu
        ;;
    esac
}

minimal_bootstrap(){
    k3d cluster list
    log_stmt "Which environment do you want to bootstrap?"
    read -r cluster_name
    kubectl config use-context k3d-$cluster_name 
    install_argocd
}