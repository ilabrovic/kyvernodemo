# Setup Openshift local

## CRC Installation

The installation of Openshift Local on your laptop is well documented on:
https://console.redhat.com/openshift/create/local

Tip: on my machine i had a corporate VPN running which caused all kinds of performance, stability and pulling issues. Turn off any VPN that you may have.

First install required packages:
- libvirt
- qemu-kvm

Download and install the openshift local crc installer package (instrictions on the website above)

Download/Copy pull secret, which the installer needs to pull images.

Initiate The Openshift local virtual machine.
Note: it will install a new package approx 4Gi if not already present in your cache. Typically this happens first time you try it, or after an crc update..
```
crc setup
```

## Minimum requirements

https://docs.redhat.com/en/documentation/red_hat_openshift_local/2.42/html-single/getting_started_guide/index#for_openshift_container_platform

Make sure to increase RAM when installing Openshift Local and you're adding additional operators
Below the crc start for Openshift Local plus Kyverno and Gitops

## Start Openshift Local

Note in advance: this step will take approx 10 minutes to complete

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

# Install Gitops operators

One of the operators we will be using to demo, is the Red Hat Gitops Operator.

## Manual installation

To manually install the operator you can do this:

In the Openshift console:
In the menu go to Operators - Operatorhub
Select Gitops operator
Install using all the defaults

Optionally, to save memory consumption, uninstall the default Gitops instance:
```
oc patch subscription.operators openshift-gitops-operator -n openshift-gitops-operator --type=merge -p='{"spec":{"config":{"env":[{"name":"DISABLE_DEFAULT_ARGOCD_INSTANCE","value":"true"}]}}}'
```

## Deploy as code!

Of course you can install it by using code in the gitops-style folder in this repo.
Dont want to install the default instance? Just uncomment the kustomization patch section in advance...
```
oc kustomize . |oc apply -f -
```


Just wait couple of minutes, the ArgoCD instance will be uninstalled by the operator automatically, freeing up resources to spend on other stuff...

# Install the Kyverno operator

You can install the opensource operator from kyverno.io, but if you also want to integrate with Nirmata, you can register your cluster to nirmate.io with all the benefits.
The registration process includes installing Kyverno on the cluster.

For note on this, see the readme in the ##./nirmata-policy-manager## folder in theis repo.

# Install CRD for objectbucketstorageclaims

One of the demo policies involve ObjectBucketstorageClaims.
Follow instructions in ./rook-ceph to install the CRD's at least to have a working Kyverno policy.

The actual storagebackend is not installed, we have not been succesfull in doing that on Openshift Local on Mac.

But the CRD is sufficient to demo the Kyverno policy.

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

## How to delete Openshift Local

```
crc stop
crc delete --clear-cache
crc cleanup
```

## Update crc

Once in a while, crc gets updated.

```
crc version
WARN A new version (2.43.0) has been published on https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/crc/2.43.0/crc-macos-installer.pkg 
```

Follow the link, install the new crc
If you have decent Disaster Recovery plan... remove/clean your old Openshift local instance and start again.
