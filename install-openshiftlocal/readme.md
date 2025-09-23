# Setup Openshift local

## CRC Installation

The installation of Openshift Local on your laptop is well documented on:
https://console.redhat.com/openshift/create/local

Tip: on my machine i had a corporate VPN running which caused all kinds of performance, stability and pulling issues. Turn off any VPN that you may have.

First install required packages:
sudo dnf install -y libvirt qemu-kvm

## Download/install crc

Download and install the openshift local crc installer package (instrictions on the website above)

```
cd
mkdir -p crc
wget https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/crc-linux-amd64.tar.xz
tar -xvf crc-linux-amd64.tar.xz
chmod ugo+x */crc

#Kill previous installment to replace the binary
#/home/ilabrovic/.crc/bin/crc daemon
PID=$(pgrep -u ilabrovic crc)
kill -9 ${PID:-9999999}

cp */crc /usr/local/bin
```

# Get pullsecret from Red Hat

Download/Copy pull secret, which the installer needs to pull images.

rm ~/Downloads/pull-secret
https://console.redhat.com/openshift/create/local
Download keyfile

# Download base image (6+ GiB)

Initiate The Openshift local virtual machine.
Note: it will install a new package approx 6Gi if not already present in your cache. Typically this happens first time you try it, or after an crc update..
```
crc setup
```

## Minimum requirements

https://docs.redhat.com/en/documentation/red_hat_openshift_local/2.42/html-single/getting_started_guide/index#for_openshift_container_platform

Make sure to increase RAM when installing Openshift Local and you're adding additional operators
Below the crc start for Openshift Local plus Kyverno and Gitops

# Clean setup

# ERRO failed to expose port :443 -> 192.168.127.2:443: listen tcp :443: bind: permission denied 
# SOLUTION set host-network-access true

crc delete --force
crc config set host-network-access true
crc cleanup
crc setup

## Start Openshift Local

Note in advance: this step will take approx 10 minutes to complete

Openshift local requires some minimal amount of resources but depending on what you want to do with it (e.g. install extra operators) you may need to increase the defaults.
These are the settings suffient for this demo environment, make sure your system has this amount of cpu and ram:
```
crc start -p ~/Downloads/pull-secret \
--cpus 8 \
--memory 18000 \
--disk-size 52 \
--log-level debug
```

## View/set all/specific settings

Some commands that may help to show your crc  configuration:
```
crc status
crc config view
crc config get memory
crc config set memory 18000
```

crc oc-env
eval $(crc oc-env)

oc login -u developer -p developer https://api.crc.testing:6443

KUBEADMIN=$(cat ~/.crc/machines/crc/kubeadmin-password)
echo KUBEADMIN: $KUBEADMIN

oc login -u kubeadmin -p ${KUBEADMIN:-NO} https://api.crc.testing:6443

oc get console cluster -o yaml |yq .status.consoleURL
echo KUBEADMIN: $KUBEADMIN
oc whoami

oc logout

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
