# Nirmata/HCS Company Demo

## Environment: Openshift Local

This demo is built on Openshift Local
Getting started with Openshift local on your laptop is well documented on https://console.redhat.com/openshift/create/local.
Personal notes are in the ./install-openshiftlocal folder in this repo.

## Nirmata Policy Manager

Nirmata Policy Manager gives you insights in your policies on your clusters.
For that to work, the cluster needs to be registered.
The cluster will then upload metrics to the portal.

Before accessing your company needs to be subscribed with Nirmata.
Some details how to register your cluster after that, can be found in the [./nirmata-policy-manager](./nirmata-policy-manager/) folder in this repo.

## Use-cases

When we build a platform, its probably not very cost efficient to run for just 1 customer or team.
An Openshift cluster is not cheap to start, so it makes sense to share a cluster among many teams.
Imagine your company has 50 teams working on a shared cluster and each team has its own set of applications to maintain.
If there was no Kyverno every team had to make their own way and possibly interfering with each other.
An administrator would also have a hard time keeping track of the nescessary resources on the cluster.
These are reasons we got started with Kyverno and helped to avoid these problems.

If you never seen Kyverno for the first time, try to remember these basics: Something happens to a resources in the cluster and you want something else to happen as well. This could be to generate another resource or validate if it meets certain requirements.

To demonstrate the power of Kyverno, we have prepared 5 use-cases.


### Use-case #1: Get started with a sandbox namespace

Getting new teams start with deploying their application in a sandbox

* New teams are keen to see that upon the first login to the cluster a sandbox namespace is already there to deploy an app.
* Using Kyverno we are automatically creating this sandbox directly when the team is onboarded on the cluster.

Notable Kyverno feature: configmap lookup.
With the Configmap lookup we establish if the cluster is production at which the team is knowledgable enough to create their own appropriate namespaces. In that case we skip this sandbox.

#### DEMO #1: Onboard a couple of teams and see what happens

Lets onboard a couple of tenants, this is done by the admin team allowing access to a new team
#Randomly select some tenant names to onboard
```
gshuf -n 20 random/groups | tee tmp/selectedgroups
```

Create groups (dev01 + those from the random selected groups) in the cluster
All groups contain the developer user
```
oc apply -f kyverno-demo/groups/dev01.yaml
cat tmp/selectedgroups|sort |while read group
do
cat kyverno-demo/groups/dev01.yaml |sed "s/dev01/$group/"|oc apply -f -
done
```

Create quota for these groups but only for the first 10...:
```
oc apply -f kyverno-demo/crq/dev01.yaml
cat tmp/selectedgroups|sort|head -n 10|while read group
do
cat kyverno-demo/crq/default.yaml |sed "s/GROUPNAME/$group/"|oc apply -f -
done
``` 

Check if sandboxes are created for any created quota:
```
oc get namespaces|grep sandbox
```


### Use-case #2: Namespace labels and annotations

Automatically include namespaces to the appropriate clusterresourcequota

* Our clusters have limited amount of capacity.
* Because multiple tenants are sharing a cluster, we are using clusterresourcequotas to manage the distribution of resources.
* To assign a clusterresourcequota to any team, we decide to give any namespace created by that team a certain annotation, and have Openshift keep track of resources in all namespaces with that annotation.
* Using Kyverno we automatically annotate each namespace  to make sure the clusterresourcequota is distributed to the right namespaces.

Notable Kyverno feature: mutate policy

#### DEMO #2: Namespaces and quotas

To aid Openshift in managing the clusterresourcequota, we need an annotation on each created namespace.
Let's verify if that happend on the sandbox namespaces we just created
```
oc get namespaces -o custom-columns=NM:.metadata.name,QUOTA:.metadata.annotations.quota|grep -v -E 'openshift|kube|kyverno|nirmata|rook|hostpath|default'
```

Openshift now correctly handles clusterresourcequotas, as we specified when we created them. For example lets take a look at dev01 crq: (see which formula we programmed in there at the 'selector'?)
```
oc get clusterresourcequota dev01 -o yaml
```



### Use-case #3: Restricting namespace names

To automatically establish which namespace belongs to which team, its decided that each namespace should start with a prefix with then name of the team.
This standardisation also helped to create the quota solution.

* Easy: just compare the name of the ns with any group the user is member of. Kyverno already provides a variable that holds a list of groups the user is member of (request.userInfo.groups)

Notable Kyverno feature(s): Kyverno provided variables and a validation rule


#### DEMO #3: Lets simulate a developer trying to create a new namespace (username: dev01)

Now lets see what happens if a developer starts working on the cluster doing work that triggers Kyverno policies:

developer takes a look at the avialable namespaces and sees the sandboxes automatically provisioned!
developer can also see rolebindings, because the group is admin in this namespace
```
export OPENSHIFTAPIURL=https://api.crc.testing:6443
oc login -u developer -p developer $OPENSHIFTAPI
oc whoami
oc get projects 
oc get rolebinding -n dev01-sandbox -o wide
```

developer creates a namespace, but failed because (s)he's no member of group dev00
Kyverno blocks that namespace
```
oc new-project dev00-psql
```
but (s)he CAN create a newspace starting with dev01! Kyverno allows namespaces starting with any of the groups dev01 is member of
```
oc new-project dev01-psql
```

Same as in the previous demo about the sandboxes, lets check if this new namespace also got the quota annotation.
So you can see 2 Kyverno policies 'working together' (namespace restrictions and auto-annotating)
To make sure resources in the new namespace are part of the right quota, an annotation is automatically added:
The developer does not have to worry about this annotation, Kyverno takes care of this!
```
oc get project dev01-psql -o yaml |grep -E 'quota|$' --color
#and lets have a look at appliciedclusterresourcequotas if the new namespace is seen:
oc get appliedclusterresourcequota -o yaml
```



### Use-case #4: Policy preconfigured gitops/argocd

Team can deploy a Gitops instance to automate deployments. Advanced teams can adjust the instance parameters if needed. Break someting: just delete the namespace and create the namespace again.

* Easy: With Kyverno we are automating the delivery of a Gitops instance. customers dont have to invent that wheel themselves
* Fast: teams can start developing pipelines faster. The policy start immediately after a team creates the namespace ending with -gitops.
* Security: out of the box in a new gitops instance (argocd resource) everyone who can log on to Openshift has access to Gitops. With kyverno we are restricting access to only to the team is concerns

Notable Kyverno feature: multiple generate rules

#### DEMO #4: The teams want to get started with Gitops. Deployment of Gitops is now automated with Kyverno!

developer creates another namespace: the gitops namespace
Kyverno picks up this namespace and automatically provisions the Gitops application
In a few moments Gitops is installed after which the route is available
Also the Kyverno policy automatically grants permissions to the group so develoeprs collegues can also work in thie project
```
oc new-project dev01-gitops
oc get argocd,pods,routes -n dev01-gitops
oc get rolebinding -o wide
```


### Use-case #5: Protect over-consuming of ObjectBucketsStorage

With Kyverno we can now protect `ObjectBucketClaims`.
Even though we can set a limit in the clusterresourcequota, Openshift doesnt do anywith with it. So we created a policy of our own. With the use of an API call in Kyverno to lookup a value in that crq resource, we can easily compare it against the requested bucketsize value and take action if needed.

* Storage on Openshift is limited
* The cluster is used by multiple tenants, one tenant should not be able to overconsume the storage, hindering other teams/tenants.
* Openshift does not support ObjectBucketstorageClaim limitation in clusteresourcequotas. So we need to come up with solution ourselves.
* We dont want tenants to contact the admin team to provision an ObjectBucketClaim. Provisioning claims should stay self-serviced by tenants.

Notable Kyverno feature: apiCall; urlPath and jmesPath

#### DEMO #5: Lets see our Kyverno solution to handle quota in objectbucketclaims in action

developer tries to create objectbuckets. some work others do not because insufficient quota!
Openshift doest not honour quota restrictions on objectbucketclaims, so we created our own Kyverno policy for this.
```
oc new-project dev01-psql
oc project dev01-psql
oc apply -f kyverno-demo/obc/dev01-small.yaml
oc apply -f kyverno-demo/obc/dev01-large.yaml
oc apply -f kyverno-demo/obc/dev01-unlimited.yaml
oc apply -f kyverno-demo/obc/dev01-toomany.yaml
```


This concludes the demo!
