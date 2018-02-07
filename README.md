# Kubernaut VM Image

The Kubernaut VM image is a pre-baked Operating System image for Amazon EC2 that has Docker and a specific Kubernetes components (`kubeadm`, `kubelet`, and `kubectl`) baked into it. This improves startup performance of freshly launched Kubernaut instances as they do not need to go through the general OS bootstrap, update and system software install process later on.

# Development Process

**TODO (plombardi)**: This section needs further enhancement.

1. Select a new base operating system Amazon Machine Image ("AMI"). This is a manual process at the moment and requires a bit of Googling. Always pick an AMI ID that is bound to the `us-east-1` region.

2. Create a new shell script to act as a provisioner in root directory. The naming format is a three segment string `kubernaut_${platform}-v${platform_version}.sh`. Valid values for `${platform}` are `k8s` for stock Kubernetes and `openshift` for RedHat's OpenShift. The `${platform_version}` should be the Kubernetes or OpenShift version with `.` (full stop) characters stripped.

3. Update the `packer.json` with appropriate new `builder` and `provisioner` instructions.

# Bake (Development)

Release bakes should be handled by the Travis CI scripts, however, for development purposes it is possible to create and publish a development image that can then be launched and used.

All of the below commands should be run from the project root.

1. Install Hashicorp's [Packer](https://packer.io) with the below command. The `packer` executable will be placed into `$(pwd)/bin` and marked executable. 

  `bin/install_packer.sh`

2. Execute the VM image bake. This process usually takes 5 to 10 minutes while the VM boots, OS packages are updated and installed and then Docker and Kubernetes are installed.

  `bin/packer_build_development.sh`

3. At the end of the bake `packer` will print the new AMI ID to use when launching a test EC2 instance. It will be at the bottom of the output and look similar to this:

  ```text
  ==> Builds finished. The artifacts of successful builds are:
  --> kubernaut_k8s-v192: AMIs were created:
  us-east-1: ami-fb808981
  ```
