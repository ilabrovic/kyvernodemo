# Install the opensource Kyverno operator

If you opt for the opensource Kyverno operator (no support by Nirmata), you can install the helm chart yourself
There is a Helm chart (recommended) installation but also a yaml based installation suitable for development environments.

For all details, look at: https://kyverno.io/docs/installation/methods/#standalone-installation

Before installing, make sure to check which version to install.
There is no 'latest' so you will need to pick an actual version number.

Check out de releasenotes on:
https://github.com/kyverno/kyverno/releases

## Yaml installation

For our demo we will install the yaml version which covers everything we need here.

oc create -f https://github.com/kyverno/kyverno/releases/download/v1.13.4/install.yaml

## Verify installation

A new namespace kyverno will be created in which the operator workload is deployed.
Verify the new namespace, running pods, and check the logs

oc get namespace kyverno
oc get pods -n kyverno --show-labels

Verifying the running version is possible to check the logs:
app.kubernetes.io/component=background-controller

Or check the running images:
oc get pods -n kyverno -o custom-columns=IMAGE:.spec.containers[*].image,CONTAINER:.spec.containers[*].name

Thats it!
Kyverno operator installed!

