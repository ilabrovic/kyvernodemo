
# Cleanup

With these notes we can clean up our Openshift local environment from a previous demo.

## Cleanup instructions

#Delete objectbucketclaims
oc delete obc --all-namespaces --all

#Deleting the sandboxes
oc get projects |grep sandbox |while read ns rest
do
  oc delete project $ns
done

#Deleting the gitops namespace
oc delete namespace dev01-gitops

#Deleting crq
oc delete clusterresourcequotas --all

#Delete cicd namespaces
#Kyverno already did this for us

#Delete dev namespaces
oc get projects |grep -e dev01 -e dev02  |while read ns rest
do
  oc delete project $ns
done

#Deleting the groups
oc delete groups --all

#Deleting users
#under constructions: delete from the secret


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
