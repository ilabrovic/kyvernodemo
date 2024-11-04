
# Nirmata Policy manager

[Nirmata Policy Manager](https://nirmata.com/policy-manager/)
Console: https://www.nirmata.io

## Documentation:

https://docs.nirmata.io/docs/nctl/getting-started/
https://www.nirmata.io/security/


## Install Nirmata CLI (nctl)

To register a cluster, the Nirmata `nctl` utility is needed.
Make sure to install this, instructions are on the [nctl documentation site](https://docs.nirmata.io/docs/nctl/installation/).

**Note:** Depending on your machine pick the right binary to download, e.g. arm architecture for Macbook M2Pro models. The demo is prepared with the following steps.

https://downloads.nirmata.io/nctl/stablereleases/

https://nirmata.io/nctl/downloads

```
curl -LO https://dl.nirmata.io/nctl/nctl_$NCTL_VERSION/nctl_$NCTL_VERSION\_linux_amd64.zip.asc
unzip nctl_4.3.1_linux_amd64.zip 
chmod u+x nctl
sudo mv nctl /usr/local/bin/nctl
nctl version
```

### nctl on Mac.

Mac-users might not be able to start nctl and getting an error that the binary cannot be checked for malicious software.
Just open it in Finder, right click 'Open' and you will get a message wether to allow executing this binary. Enter yes, and from there you should be good to use the binary from the commandline.



## kubectl

nctl Also requires the kubectl binary.
Running Openshift you will probably only have the oc client.
Just copy the oc binary to kubectl binary and youre good to go.

**Note:** a symbolic link from oc to kubectl did not work last time i checked.



## Register cluster to Nirmata Policy Manager dashboard

Make sure you are logged in at the Nirmata console
https://www.nirmata.io/webclient/#dashboards/overview

In the dashboard go to Clusters - Add Cluster

Name the cluster: uppercases not allowed, only lowercase
In the compliance standards, de-select for now: Pod Security Standards - Restricted.
If the nctl command does not include an API key but just a placeholder <key>, use the link to "Generate an API key"

Login as kubeadmin on the Openshift local cluster
Copy paste the login instruction
Copy past the registration instruction

```
nctl login --url https://www.nirmata.io ...
nctl add cluster --onboarding-token ...
```

Now wait for the Enterprise Kyverno installation to finish
Depends mainly on your network bandwith to pull additional container images to the cluster for the workload to start.

You can observe the nirmata, nirmata-system and kyverno namespaces and their workload if you feel its taking too long.

If registering is done, click on `I have run the commands` in the Nirmata console, and verify that the new cluster is connected.


