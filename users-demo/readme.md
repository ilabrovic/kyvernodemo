# Adding demousers

## Backup yaml

oc get secret -n openshift-config htpass-secret -o yaml > htpass-secret.yaml
cp -n -v htpass-secret.yaml htpass-secret.backup.yaml

## Extract the htpass file

oc extract -n openshift-config secret/htpass-secret --to=.

#Create an initial backup
#-n do not overwrite existing backup
cp -n -v htpasswd htpasswd.backup

#Add newline
echo >> htpasswd

#Add developeraccounts to htpass file

cat ../random/users|while read username
do
  htpasswd -b htpasswd ${username} ${username}
done

htpasswd -b -n user2 'p@ssw0rd' >> htpasswd
#Update the secret
oc set data -n openshift-config secret/htpass-secret --from-file=htpasswd=htpasswd

#Check the operator logs:
oc get pods -n openshift-authentication-operator -o wide
oc logs -n openshift-authentication-operator -l app=authentication-operator

#Test login
