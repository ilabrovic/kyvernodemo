# Test privileges


oc project kyverno
TOKEN=$(oc create token kyverno-background-controller)
export KUBECONFIG=./kyverno.kubeconfig
oc login --token $TOKEN $OPENSHIFTAPIURL
oc project kyverno
oc auth can-i create namespace


Or as cluster admin kubeadmin:

oc auth can-i create namespace

oc auth can-i create namespace --as=developer

oc auth can-i create namespace --as=system:serviceaccount:kyverno:kyverno-background-controller


