## Troubleshooting

### gitops is taking forever to start

oc get events --sort-by=.lastTimestamp 
Network issues

Did openshiftlocal start without internet connection?
If quay.io is not available right from the beginning,
all kinds of things can go wrong

Did openshiftlocal start while running a VPN client?
Don't do this..


### If a policy is not working check the logs

oc logs -n kyverno -l app.kubernetes.io/component=admission-controller
oc logs -n kyverno -l app.kubernetes.io/component=background-controller


### Troubleshooting policys to new Kyverno version

In a validat rule, oc keeps saying policy changed.

!!Not verified:

When policy is not included with allowExistingViolations, 
Just Add this degfault key an its fixed.

      allowExistingViolations: true