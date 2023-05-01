#!/bin/bash

local_cluster() {
    #export K3D_FIX_CGROUPV2=1 ; 
    k3s_image="rancher/k3s:v$K3S_VERSION-k3s1"
    
    info "Current Environments:"
    k3d cluster list

    if [[ '' = $1 ]]; then
        log_stmt "What do you want to name your environment?"
        read -r cluster_name 
        echo "Installing $k3s_image"
    else
        cluster_name=$1
    fi

    check_cluster_exists $cluster_name
    info "Deploying local cluster named $cluster_name, with network ingress ports: $HTTP_INGRESS_PORT, $HTTPS_INGRESS_PORT"
    sed "s|K3S_VERSION_REPL|$k3s_image|g; s|HTTP_PORT_REPL|$HTTP_INGRESS_PORT|g; s|HTTPS_PORT_REPL|$HTTPS_INGRESS_PORT|g; s|API_SERVER_PORT_REPL|$API_SERVER_PORT|g; s|CLUSTER_NAME_REPL|k3d-env-$cluster_name|g;" "$(pwd)/config/cluster.tmpl" > "$(pwd)/config/cluster.yaml"
    
    tld="$TLD.local"
    env_tld="${cluster_name}.${tld}"
    
    info "Adding the following to your hosts file: $tld, $env_tld"

    add-host  127.0.0.1 $tld
    add-host  127.0.0.1 $env_tld

    ingressmenu $cluster_name $HTTPS_INGRESS_PORT $env_tld
    
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

    tld="$TLD.local"
    env_tld="${cluster_name}.${tld}"

    info "Removing the following to your hosts file: $tld, $env_tld"

    remove-host  127.0.0.1 $tld
    remove-host  127.0.0.1 $env_tld
}

default_ingress_options(){
    info_pause_exec_options "Proceed with local environment named ${On_Cyan} $1 ${Off}?" "k3d cluster create $1 --config $configfile"
    switch_context $1
    info "Your cluster ingress is ready.  Trying ingress using port $2."
    curl -i localhost:$2
}

nginx_ingress_options(){
    info_pause_exec_options "Proceed with local environment named ${On_Cyan} $1 ${Off}, using ${On_Cyan} NGINX ${Off} ingress?" "k3d cluster create $1 --k3s-arg='--disable=traefik@server:0' --wait  --config $configfile"
    info "Cluster created!"
    switch_context $1
    #install_metal_lb $1
    info "Waiting for NGINX to complete.  This can take up to 5 minutes."
   
    echo
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v$NGINX_CONTROLLER_VERSION/deploy/static/provider/aws/deploy.yaml -n ingress-nginx

    wait_for_deployment ingress-nginx-controller ingress-nginx
    sleep 5

    info "Your cluster ingress is ready.  Trying ingress: https://$3:$2"
    curl -ik https://$3:$2
}

traefik_ingress_options(){
    info_pause_exec_options "Proceed with local environment named ${On_Cyan} $1 ${Off}, using ${On_Cyan} NGINX ${Off} ingress?" "k3d cluster create $1 --k3s-arg='--disable=traefik@server:0' --wait --volume '$(pwd)/manifests/traefik-ingress.yaml:/var/lib/rancher/k3s/server/manifests/traefik-ingress.yaml' --config $configfile"
    info "Cluster created!"
    switch_context $1
    #install_metal_lb $1
    info "Waiting for Traefik to complete.  This can take up to 5 minutes."
    wait_for_job helm-install-ingress-controller-traefik kube-system
    wait_for_deployment ingress-controller-traefik ingress-traefik
   
    info "Your cluster ingress is ready.  Trying ingress: https://$3:$2"
    curl -ik https://$3:$2
}

ingressmenu() {
    echo -ne "
$(magentaprint 'Select an ingress option:')
$(greenprint '1)') NGINX
$(greenprint '2)') Traefik v2
$(redprint '0)') Exit
""
Choose an option:  "
    read -r ans
    case $ans in
    9)
        echo ""
        default_ingress_options $1 $2
        ;;
    1)
        echo ""
        nginx_ingress_options $1 $2 $3
        ;;
    2)
        echo ""
        traefik_ingress_options $1 $2 $3
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