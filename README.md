## Table of Contents

- [About this Application](#password-generator-app)
- [Deploy to eks cluster using Github Workflow](#deploy-to-eks)

### Password Generator App

In this project, I am trying to make a password generator in which a user can create custom strong passwords and copy them in order to use them other websites or platforms.

<p align="center">
  <img src="assets/pass-generator.gif" width="600">
</p>

#### Idea
- Get All Symbol Characters ( @#$½§ etc.) - true-false
- Get All Numbers ( 1265 etc. ) - true-false
- Get Characters ( abcABC etc. ) - true-false
- Get Length of the password ( 17 etc. ) - required
- At least one option must be selected if not toast error message
- Add All Include Characters to Array
- Loop to That length
  - Get Random Index between 0-(length-1)
  - Using That Index get that character characters[index]
  - add that character to new password
- Copy That Password To Clipboard

### Deploy to EKS

 This repo is configured with [github workflow](https://github.com/vijaySamanuri/password-manager/tree/master/.github/workflows) which does the following series of tasks:
 * build docker image
 * tag docker image
 * push to docker registry (configured to push to docker hub, we can change it to whatever we want)
 * scan the docker image for any vulnerabilities
 * deploy the image to EKS cluster in `password-manager` namespace.
 * verify the deployment
 
 This workflow automatically triggers when you merge a tagged commit (tag starting with `v*`) in master branch
 
 for example:
 
 ```shell
    git clone https://github.com/vijaySamanuri/password-manager
    cd password-manager
    <make some file changes>
    git add .
    git commit -m "some change"
    git tag v0.5.0
    git push --atomic origin master v0.4.0
  ```
  > Note: we are using this tag for image tagging
  
  We can change the trigger to on every push or every pull request and the image tagging policy can be changed to commit-id `git.sha` 
  ```yaml
    on: [push, pull_request]
  ```
 
 #### prerequisites
 
 * You have a container registry and the credentials
   
   Here as an example i made use of [docker hub](https://hub.docker.com/r/vijaysamanuri/password-manager/tags?page=1&ordering=last_updated) as container registry and the credentials configured in github secrets.
   Configure the following Github secrets
   `DOCKER_USERNAME`
   `DOCKER_PASSWORD`
   
   In case you want to use any other container registry change the `DOCKER_REGISTRY` env in workflow [yaml](https://github.com/vijaySamanuri/password-manager/blob/master/.github/workflows/main.yml) and `DOCKER_EMAIL` is optional.
 
   > NOTE: if you use ECR as the container registry with the same aws account of EKS cluster then image pull secret is not required as AWS allows eks to ecr authentication implicitly.
   
   
 * You have EKS cluster provisioned 
 
   use the [terraform scripts](https://github.com/vijaySamanuri/eks-terraform/blob/main/README.md) to provision sample demo eks cluster.
   
 * create a namespace in the eks cluster
   ```shell
   kubectl apply -f https://github.com/vijaySamanuri/eks-terraform/blob/main/namespace.yaml
   ```
   this creates namespace called `password-manager` in case you want to change the name please make the change in env `NAMESPACE` in  workflow [yaml](https://github.com/vijaySamanuri/password-manager/blob/master/.github/workflows/main.yml)
 
 * create `KUBECONFIG` secret in github
   ```shell
   cat $HOME/.kube/config | base64
   ```
   > Note: eks makes use of dynamic kubeconfig, if you look at kubeconfig file you will see below `exec` block in `$HOME/.kube/config`
   ```yaml
   exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - --region
      - us-east-2
      - eks
      - get-token
      - --cluster-name
      - eks-demo
      command: aws
      env: null
   ```
   
   which implies it dynamically gets the token using `get-token` command of aws cli, but we need a static kubeconfig to be kept as github secret.
   
   So create a service account which has access to create workloads in the above created namespace and configure kubeconfig file with service account token.
   
   [Here](https://github.com/vijaySamanuri/eks-terraform/blob/main/scripts/create-admin-token.sh) is a handy script which creates admin token and configures the existing kubeconfig file.
   ```shell 
      cd eks-terraform/scripts/
      bash create-admin-token.sh
   ```
   or you can create a service account with least privileges and configure the kubeconfig file.


#### Access the Deployed Application

```shell
   kubectl get svc -n password-manager
```
and access the external-ip in browser.

Make some source code changes, push a tagged commit and refresh the browser.

Happy Deploying :)
   
  
