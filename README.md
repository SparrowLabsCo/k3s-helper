# k3s-helper

## This is a basic helper library to get started with k3s and k3d quickly.  Tested using:

- Mac M1
- Ubuntu 22.04

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