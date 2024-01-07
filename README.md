# Task3_Terraform + Flux на kind_cluster

Firts step we change our cluster in module in main.tf
```hcl
module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster?ref=cert_auth"
}
```
next
```sh
✗ terraform init
Terraform has been successfully initialized!
```
check code
```sh
✗ tf validate
Success! The configuration is valid.
```
and apply
```sh
✗ tf apply
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```
check state list
```sh
$ tf state list
module.flux_bootstrap.flux_bootstrap_git.this
module.github_repository.github_repository.this
module.github_repository.github_repository_deploy_key.this
module.kind_cluster.kind_cluster.this
module.tls_private_key.tls_private_key.this
```
add bucket
```hcl
terraform {
  backend "gcs" {
    bucket = "dennyyyyyyy-secret"
    prefix = "terraform/state"
  }
}
```
```sh
$ gsutil mb gs://dennyyyyyyy-secret
Creating gs://dennyyyyyyy-secret/...

$ gsutil ls gs://dennyyyyyyy-secret
gs://dennyyyyyyy-secret/terraform/
```
```sh
$ terraform init
```
check ns and flux-system pod
```sh
✗ k get ns
NAME                 STATUS   AGE
default              Active   7m21s
flux-system          Active   4m29s
kube-node-lease      Active   7m21s
kube-public          Active   7m21s
kube-system          Active   7m21s
local-path-storage   Active   7m16s

✗ k get po -n flux-system
NAME                                       READY   STATUS    RESTARTS   AGE
helm-controller-5b48549d95-4mw5n           1/1     Running   0          4m45s
kustomize-controller-5c8878fd86-hs8fn      1/1     Running   0          4m45s
notification-controller-59696fbb58-89ls8   1/1     Running   0          4m45s
source-controller-fc5555fb-ql56l           1/1     Running   0          4m45s
```
add to repo new dir demo and file ns.yaml where will be manifest for test
```sh
apiVersion: v1
kind: Namespace
metadata:
  name: demo
```
after that Flux define changes and deploy new ns, lets do it for an example
```sh

✗ flux logs -f
2024-01-07T00:05:08.750Z info GitRepository/flux-system.flux-system - stored artifact for commit 'add ns.yaml' 
2024-01-07T00:05:09.363Z info Kustomization/flux-system.flux-system - server-side apply for cluster definitions completed 
2024-01-07T00:05:09.503Z info Kustomization/flux-system.flux-system - server-side apply completed 
2024-01-07T00:05:09.529Z info Kustomization/flux-system.flux-system - Reconciliation finished in 757.10809ms, next run in 10m0s 

✗ k get ns 
NAME                 STATUS   AGE
default              Active   11m
demo                 Active   29s
flux-system          Active   8m45s
kube-node-lease      Active   11m
kube-public          Active   11m
kube-system          Active   11m
local-path-storage   Active   11m
```
now prepare with CLI Flux generation new manifest
```sh
$ git clone https://dennyyyyyyy:ghp_**************@github.com/dennyyyyyyy/flux-gitops.git
$ cd ../flux-gitops 
$ flux create source git kbot \
    --url=https://github.com/dennyyyyyyy/kbot \
    --branch=main \
    --namespace=demo \
    --export > clusters/demo/kbot-gr.yaml
$ flux create helmrelease kbot \
    --namespace=demo \
    --source=GitRepository/kbot \
    --chart="./helm" \
    --interval=1m \
    --export > clusters/demo/kbot-hr.yaml
$ git add .
$ git commit -m"add manifests"
$ git push

$ flux logs -f
2024-01-07T00:07:07.382Z info GitRepository/flux-system.flux-system - stored artifact for commit 'add manifest' 
2024-01-07T00:07:08.017Z info Kustomization/flux-system.flux-system - server-side apply for cluster definitions completed 
2024-01-07T00:07:08.172Z info Kustomization/flux-system.flux-system - server-side apply completed 
2024-01-07T00:07:08.203Z info Kustomization/flux-system.flux-system - Reconciliation finished in 794.254689ms, next run in 10m0s 
2024-01-07T00:08:07.129Z info GitRepository/flux-system.flux-system - garbage collected 1 artifacts  
```
check pod in our project and destroy IAC
```sh
$ k get po -n demo
NAME                         READY   STATUS             RESTARTS       AGE
kbot-helm-5b48549d95-4mw5n   0/1     CrashLoopBackOff   5 (100s ago)   8m

$ tf destroy
```
![1](.img/SCR-20240106-setd.png)
![2](.img/SCR-20240106-seyz.png)
![3](.img/SCR-20240106-sfhk.png)
![4](.img/SCR-20240106-slzv.png)
![5](.img/SCR-20240107-bsfy.png)
