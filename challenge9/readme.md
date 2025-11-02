# Challenge 9: Continuous Deployment (CD) to Kubernetes 🚀

## Objective: 
Integrate a Continuous Deployment step into your GitHub Actions workflow to automatically update the Kubernetes Deployment with the newly built and pushed Docker image tag.

This challenge focuses on CI/CD Orchestration, Kubernetes Deployment Strategies, and Automation Scripting.

## The Scenario
Immediately after the Docker image is successfully built, tagged with the commit SHA, and pushed to Docker Hub (from Challenge 8), the CD pipeline must take over. It needs to ensure the running application is updated with zero downtime.

## The Challenge

- Deployment Update Strategy: Explain which Deployment Strategy (a field in the Deployment manifest, defaulted in your Challenge 6 manifest) is the ideal choice for ensuring zero-downtime updates in this scenario, and why.

- GitHub Actions CD Script: Write the Shell Script snippet that performs the three critical steps for the CD job, assuming the deployment.yaml file (from Challenge 6) is in the root directory:

- Tag Retrieval: Get the 7-character commit SHA tag (e.g., stored as a variable NEW_TAG).

- Manifest Patching: Use the sed utility to find and replace the old hardcoded image tag (rajrishab/challenge2:1.8) with the new dynamic tag (rajrishab/challenge2:${NEW_TAG}) inside deployment.yaml.

- Application: Apply the updated manifest to the Kubernetes cluster using the kubectl apply command.

- Cluster Authentication: In a real-world scenario, what is the most secure and common method for a GitHub Actions runner (which is external) to authenticate and gain permission to execute kubectl apply against a remote, production-grade Kubernetes cluster (like AWS EKS or GCP GKE)?

## Your Deliverable:

The name of the Kubernetes Deployment Strategy and a one-sentence reason why.

The complete Shell Script snippet (bash) for the CD steps.

A description (1-2 sentences) of the secure authentication method.

Good luck! This connects the final dots in your DevOps pipeline.



## Solution

### Deployment Update Strategy:
The rolling update strategy is the ideal strategy to update the deployment with the new image, we can acheive it using both imperative command and imperative object configuration

1. in imperative command we use the command line to update the image of our deployment 
`kubectl set image deployments/my-app-deployment container=rajrishab/challeneg9:ascbasd`

2. in imperative object configuration we update the deployment configuration and then appy the configuration using following command
`kubectl apply -f deployment.yaml`


In both of these approaches kubernetes will update the pod one by one, meaning it will scheudled on the nodes with available resources and it will wait for the pod to get created and after that the pod is created it will remove the old pods from the cluster.

###  GitHub Actions CD Script:

We can use the following CD steps to update our deployment

```yaml
deploy:
    runs-on: kub-runner 
    needs: build
    steps: 
      - name: checkout
        uses: actions/checkout@v4
      - name: Download Kubectl binaries
        run: curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      - name: Install Kubectl
        run: sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      - name: updating config
        run: |
          IMAGE_TAG="${{ needs.build.outputs.tag }}"
          sed -i "s|image:.*|image: ${IMAGE_TAG}|" ./challenge9/kubernetes/deployment.yaml
      - name: Deploy the app to kubernetes
        run: |
             kubectl config set-cluster minikube --server=https://192.168.49.2:8443 --insecure-skip-tls-verify=true
             kubectl config set-credentials my-remote-access-user --token="${{ secrets.TOKEN }}"
             kubectl config set-context my-remote-access-context --cluster=minikube  --user=my-remote-access-user --namespace=default
             kubectl config use-context my-remote-access-context
             kubectl get pods --all-namespaces
             kubectl config view
             echo "the value of TAG is ${{ needs.build.outputs.tag }}"
             kubectl apply -f ./challenge9/kubernetes/deployment.yaml
```


## Tag Retrieval

We can retrieve the image the from the previous build step using the following command

`IMAGE_TAG="${{ needs.build.outputs.tag }}"`

and then we can update the deployment config file using the following command 
`sed -i "s|image:.*|image: ${IMAGE_TAG}|" ./challenge9/kubernetes/deployment.yaml`




## Deployment updation

We can prepare our clusetr for updation by following steps


1. Install the cert-manager to manager the TLS certificates using the following command we will use it to

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.15.1 \
  --set crds.enabled=true
```

2. then generate a PAT with repo permissions so that we can register our pod as remote runner in our github

```bash

helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update
helm upgrade --install --namespace actions-runner-system --create-namespace \
  --set=authSecret.create=true \
  --set=authSecret.github_token="REPLACE_YOUR_PAT_HERE" \
  --wait actions-runner-controller actions-runner-controller/actions-runner-controller
```

3. Then create a runner deployment which will act as the remote runner to run our CD pipeline

```yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: kubernetes-runner
spec:
  replicas: 1
  template:
    spec:
      serviceAccountName: runner-sa # This ServiceAccount needs permissions
      repository: your_github_username/your-repository-name # Update to your target repo (e.g., siddhant-khisty/key-store-gin)
      labels:
        - "kubernetes-runner" # Label to target this runner in your workflow
```

4. then create a service account which we will use to authenticate and authorize our remote runner to make requests/changes to our cluster using following command

`kubectl create sa runner-sa -n actions-runner-system`


5. then create a ClusterRole and ClusterRoleBinding to assign the necessary permissions to the service account using following config

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: runner-deployments
rules:
- apiGroups: ["apps","","clusterrole.rbac.authorization.k8s.io"]
  resources: ["*"]
  verbs: ["get","list","watch","create","update","patch","delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: runner-deployments-binding
subjects:
- kind: ServiceAccount
  name: runner-sa
  namespace: actions-runner-system
roleRef:
  kind: ClusterRole
  name: runner-deployments
  apiGroup: rbac.authorization.k8s.io
```

6. Then generate the token of the service account which we will save in our github repo as secret. so that our github action can use the token to register our service account in the remote runner, when remote runner will make request to our API server it will have this TOKEN so that our API server can authenticate and authorize it.

`TOKEN=$(kubectl create token runner-sa --duration=8760h --namespace=actions-runner-system)`

7. then make the updates and push the code to repo on main branch for the CI/CD pipeline to trigger.

