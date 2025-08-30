## Troubleshooting

### CRC not starting

crc status
DAEMON not started?

cat ~/.crc/crcd.log
DNS issues?

cat /etc/resolv.conf
do we have dns entry?

SSH issues?
Are there errors regarding ssh?
cat ~/.crc/crc.log

time="2024-11-06T12:28:14+01:00" level=debug msg="SSH command results: err: dial tcp 127.0.0.1:2222: connect: connection refused, output: "

Try this setting see if anything improves:
crc config set disable-update-check true


### gitops is taking forever to start

oc get events --sort-by=.lastTimestamp 
Network issues

Did openshiftlocal start without internet connection?
If quay.io is not available right from the beginning,
all kinds of things can go wrong

Did openshiftlocal start while running a VPN client?
Don't do this..

### urs

Any urs left behind to check?
oc get ur -n kube-kyverno

### policy describe

oc describe clusterpolicy sandbox-namespace


### If a policy is not working check the logs

oc get pods -n kyverno

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