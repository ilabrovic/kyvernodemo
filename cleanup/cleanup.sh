
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