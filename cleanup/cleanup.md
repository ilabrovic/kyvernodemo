
# Cleanup

With these notes we can clean up our Openshift local environment from a previous demo.

## Cleanup instructions
./cleanup/cleanup.sh


## Final checks after cleanup

#Which namespaces do we have left?
#Should only be default, nirmata and kyverno namespaces
#Skip openshift because thas a long list...
oc get namespaces |grep -v openshift

#Is kyverno clean?
oc get ur -n kyverno

#Check the kyverno logs
stern -l app.kubernetes.io/component=admission-controller --no-follow

fix if you can:
oc delete ur --all
