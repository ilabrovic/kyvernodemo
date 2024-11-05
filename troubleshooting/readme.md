## Troubleshooting

### gitops is taking forever to start

oc get events --sort-by=.lastTimestamp 
Network issues

Did openshiftlocal start without internet connection?
If quay.io is not available right from the beginning,
all kinds of things can go wrong

Did openshiftlocal start while running a VPN client?
Don't do this..

### did we deploy the config?

oc get configmap -n kyverno kyverno-parameters -o yaml

### Any pod in trouble?

oc get pods --all-namespaces|grep -v Running  

### no issues with kyverno workload?

oc get pods -n nirmata --show-labels

oc logs -n nirmata -l app=nirmata-kube-controller
oc logs -n nirmata -l app=opentelemetry

oc get pods -n nirmata-system --show-labels

oc logs -n nirmata-system -l app.kubernetes.io/name=nirmata-kyverno-operator

oc get pods -n kyverno --show-labels

oc logs -n nirmata -l app=nirmata-kube-controller

oc logs -n kyverno -l app.kubernetes.io/component=cleanup-controller

### check kyverno running version

oc get pod -n kyverno -o yaml | grep image:


### api server

Anything in the api server logs?

oc logs -n openshift-apiserver -l apiserver=true

### If a policy is not working check the logs

oc logs -n kyverno -l app.kubernetes.io/component=admission-controller
oc logs -n kyverno -l app.kubernetes.io/component=background-controller

024-11-05T19:59:46Z	ERROR	dynamic-client	dclient/discovery.go:100	schema not found	{"gvk": "quota.openshift.io/v1, Kind=ClusterResourceQuota", "error": "kind 'ClusterResourceQuota' not found in groupVersion 'quota.openshift.io/v1'"}

GVK = Group Version Kind

### Check kyverno controller serviceaccount

TOKEN=$(oc create token -n kyverno kyverno-background-controller)
oc login --token $TOKEN
oc whoami
oc get clusterresourcequotas
oc get clusterresourcequotas --v=8


### Troubleshooting policys to new Kyverno version

In a validat rule, oc keeps saying policy changed.

!!Not verified:

When policy is not included with allowExistingViolations, 
Just Add this degfault key an its fixed.

      allowExistingViolations: true