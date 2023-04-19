.PHONY: prep start destroy 
OS?=linux
K3D_VERSION?=5.3.0
K3S_VERSION?=1.22.2
ARGOCD_VERSION?=2.6.7
ARCH?=amd64
HTTP_INGRESS_PORT?=8080
HTTPS_INGRESS_PORT?=8443
API_SERVER_PORT?=6443
export ARCH
export OS
export K3S_VERSION
export ARGOCD_VERSION
export K3D_VERSION
export HTTP_INGRESS_PORT
export HTTPS_INGRESS_PORT
export API_SERVER_PORT
start:
	scripts/start.sh $(name)

# destroy:
# 	scripts/destroy.sh $(name)

# prep:
# 	scripts/libs/init.sh