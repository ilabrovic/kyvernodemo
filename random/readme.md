# Random data

podman and docker are using a large list of names to randomize containernames.
We'll download this list, to reuse that for generating 'random' users en groupname.

Download the random data source from github
Extract the 2 lists for users and groups
Then use shuf to randomly select some rows from these lists

```
wget https://raw.githubusercontent.com/containers/podman/refs/heads/main/vendor/github.com/docker/docker/pkg/namesgenerator/names-generator.go
cat names-generator.go|gsed -n "/agnesi/,/zhukovsky/p" |grep -v '//'|tr -d '", \t' |grep -v "^$" >users
cat names-generator.go|gsed -n "/angry/,/youth/p" |tr -d '", \t' >groups

gshuf -n 3 users
gshuf -n 3 groups
```
