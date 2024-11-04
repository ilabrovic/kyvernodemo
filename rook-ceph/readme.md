# rook-ceph

With these notes we are trying to get objectbucket storage on openshift local up and running.
We need this to demonstrate the Kyverno policy that handles quota on objectbucketstorage.

So far attempts have failed, but even without storage, or running the rook operator, it's sufficient for the demo to install the CRD's.

Online reference:

https://developers.redhat.com/articles/2022/07/13/install-storage-your-application-cluster-using-rook#log_in_to_the_openshift_cluster


## Install CRD's

oc apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/crds.yaml
oc apply -f https://raw.githubusercontent.com/rook/rook/master/deploy/examples/common.yaml
 
## Allow everyone to create obc

Operator comes with several roles but none allow developers to create their own obc

Add this role with the aggreation to admin option:

oc kustomize . | oc apply -f -

or (its only 1 yaml..):
oc apply -f developers-objectbucketclaims.yaml




# Under construction

The next paragraphs are just notes on our attempts to get rook operational
So far unsuccesfull, perhaps the notes will help in additional attempts...

# Adding diskspace

The idea is this:

Get into the virtual machine crc how disk layout looks like now
Create a disk image on the host
Add that disk to the virtual machine
check the crc machine again
create a CR to assign the new disk for storage
and test creating a objectbucketclaim

However we have not been able to find a way to add a second virtual disk tot the Openhift Local VM instance.

## Install qemu

https://www.qemu.org/download/#macos

brew install qemu

## get into the crc machine

oc get nodes

oc debug nodes/crc

-> something off with label kyverno policy.
its triggers something must be happening to the namespace but the policy cant deal with namespace name = null??
Adding null operation in the policy to overcome this.

sh-5.1# df -H / |grep -v overlay |grep -v tmpfs
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda4        49G   41G  8.3G  83% /

disk=vda

## Create disk

qemu-img create -f raw /Users/${USER}/.crc/machines/crc/crc-extra-disk 4G

## Add disk to crc machine. Heres where we are stuck

sudo virsh attach-disk crc --source /Users/${USER}/.crc/machines/crc/crc-extra-disk --target vdb --cache none

with sudo:

fout: verbinden met de hypervisor mislukte
fout: Operation not supported: Cannot use direct socket mode if no URI is set. For more information see https://libvirt.org/kbase/failed_connection_after_install.html

without sudo:

fout: verkrijgen van domein 'crc' mislukte



