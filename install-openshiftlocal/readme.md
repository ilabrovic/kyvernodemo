# Setup Openshift local

## Installation

The installation of Openshift Local on your laptop is well documented on: https://console.redhat.com/openshift/create/local

Tip: on my machine i had a corporate VPN running which caused all kinds of performance, stability and pulling issues. Turn off any VPN that you may have.

First install required packages:
- libvirt
- qemu-kvm

Download and install the openshift local crc installer package (instrictions on the website above)

Download/Copy pull secret, which the installer needs to pull images.

Initiate The Openshift local virtual machine:
```
crc setup
```

## Start Openshift Local

Openshift local requires some minimal amount of resources but depending on what you want to do with it (e.g. install extra operators) you may need to increase the defaults.
These are the settings suffient for this demo environment:

#Specs to start on system with 12core/32GB Ram (Macbook M2pro)
```
crc start \
--cpus 8 \
--memory 18000 \
--disk-size 46 \
--log-level debug
```

## View/set all/specific settings

Some commands that may help to show your crc  configuration:
```
crc config view
crc config get memory
crc config set memory 18000
 ```

For your convenience save the generated kubeadmin token to a profilescript to quickly login to openshift and switch bewith kubeadmin and developer during your work and demo.

An '.openshiftlocal' exampleprofile is in the ./profile subfolder in this repo

## How to delete Openshift Local:

```
crc delete --clear-cache
```


# Install Gitops operators

One of the operators we will be using to demo, is the Red Hat Gitops Operator.

In the Openshift console:
In the menu go to Operators - Operatorhub
Select Gitops operator
Install using all the defaults

Optionally, to save memory consumption, uninstall the default Gitops instance:
```
oc patch subscription.operators openshift-gitops-operator -n openshift-gitops-operator --type=merge -p='{"spec":{"config":{"env":[{"name":"DISABLE_DEFAULT_ARGOCD_INSTANCE","value":"true"}]}}}'
```


# Install Kyverno policies

As an administrator, we will upload the specific Kyverno policies. What we need are:

* *additional rbac permissions for the Kyverno controller to handle CRD Custom Resource Definitions and createing namespaces
* *additional rbac permissions so that Kyverno can generate rolebindings based on roles policies are distributing
* Install customer/cluster dependable parameters, (name of the cluster to add banners, settings wether its production or not to (not) create sandboxnamespaces.
* And install the Kyverno policies themselves

Its all prepared in this repository, just need to run:
```
oc kustomize kyverno-assets |oc apply -f -
```
