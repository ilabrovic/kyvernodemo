
#Base encode the logo
base64 -i /Users/ivanlabrovic/Downloads/politielogo.png

#Insert into configmap
create configmap argocd-ui-custom --from-file=custom.css

