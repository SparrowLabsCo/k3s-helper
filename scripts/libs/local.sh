#!/bin/bash

local_cluster() {
    #export K3D_FIX_CGROUPV2=1 ; 
    k3s_image="rancher/k3s:v$K3S_VERSION-k3s1"
    sed -i '' "s|K3S_VERSION_REPL|$k3s_image|g" "$(pwd)/config/cluster.yaml"
    echo "Installing $k3s_image"
    log_stmt "What is your environment name?"
    read -r cluster_name 
    ingressmenu $cluster_name
   
    if (k3d cluster list | grep -q "$cluster_name"); then
        kubectl config use-context k3d-$cluster_name 
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
}

nginx_ingress_options(){
    info_pause_exec_options "Proceed with local environment named ${On_Cyan} $1 ${Off}, using ${On_Cyan} NGINX ${Off} ingress?" "k3d cluster create $1 --k3s-arg='--disable=traefik@server:0' --volume '$(pwd)/manifests/nginx-ingress.yaml:/var/lib/rancher/k3s/server/manifests/nginx-ingress.yaml' --config $configfile"
}

traefik_ingress_options(){
    info_pause_exec_options "Proceed with local environment named ${On_Cyan} $1 ${Off}, using ${On_Cyan} NGINX ${Off} ingress?" "k3d cluster create $1 --k3s-arg='--disable=traefik@server:0' --volume '$(pwd)/manifests/traefik-ingress.yaml:/var/lib/rancher/k3s/server/manifests/traefik-ingress.yaml' --config $configfile"
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
        default_ingress_options $1
        ;;
    2)
        echo ""
        nginx_ingress_options $1
        ;;
    3)
        echo ""
        traefik_ingress_options $1
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