# setup new sshkey authentication for github

## Create a new ssh keypair

Create a new ssh keypair

```
ssh-keygen -P '' -t rsa -b 4096 -f ~/.ssh/github-keypair1
```

```
Copy the private keyfile to ~/.ssh if you didnt specify a full path in the previous command
Make sure to set the correct permissions to the private key!

mv github-keypair1 ~/.ssh
chmod 600 ~/.ssh/github-keypair1
```

Configure ssh to use this key with github

```
add to ~/.ssh/config:

Host github.com
  Hostname github.com
  User MAINTAINER
  IdentityFile /home/LOCALUSER/.ssh/github-keypair1
```

## Update security in github.com

Go to your profile page in github.com
Settings
SSH and GPG Keys
Add the public key here


## Clone the repo

Now test if the keypair is correctly distributed by trying to clone the repo

```
git clone git@github.com:MAINTAINER/openshiftlocal.git
```

