# k3d/s-helper

## This is a basic helper library which uses [k3d](https://github.com/k3d-io) to get started running a [k3s](https://github.com/k3s-io/k3s) Kubernetes cluster on your local development environment, with options for some opinionated Day-2 cluster bootstrapping. <br/> <br/>

## Prerequisites: make, docker, k3d, kubectl, helm  <br/> <br/>

## Tested using:

- Mac M1
- Ubuntu 22.04

## Fully Tested:
- k3d version: `5.4.9`
- k3s version: `v1.22.2-k3s1`
- ArgoCD version: `2.6.7`
- NGINX Helm Chart: `4.6.0`
- Traefik Helm Chart: `10.0.0`

### There are two mandatory env vars that need to be set:
```
OS
ARCH
```

Supported OS values are `darwin, linux`.  Supported ARCH values are `arm64, amd64`

### To run the helper on a Mac M1:

```
OS=darwin ARCH=arm64 make
```

### To run the helper on a Linux based environment:

```
OS=linux ARCH=amd64 make
```

Default values can be seen by inspecting the [Makefile](https://github.com/SparrowLabsCo/k3s-helper/blob/main/Makefile) - they can be overridden by passing flags at runtime.  For example, to override the Kubernetes version:

```
OS=linux ARCH=amd64 K3S_VERSION=1.26.3 make
```
