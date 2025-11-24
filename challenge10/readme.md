## Challenge 10: Troubleshooting and Debugging the Pipeline 🐛

**Objective:** Demonstrate strong troubleshooting skills by diagnosing and solving common pipeline failures.

This challenge focuses on **Troubleshooting (Kubernetes/Docker/CI)** and **Interview Prep**.

### The Scenario

A developer pushes a change, and the new Deployment fails to update. Your job is to diagnose the common causes for each of these three failure scenarios:

1.  **Kubernetes Deployment Failure:** The `web-app-deployment` is stuck in a state where the new Pods are created, but they remain in the **`Init: 0/1`** or **`ImagePullBackOff`** state.
2.  **Liveness Probe Failure:** The Pods launch successfully and transition to a **`Running`** state, but the deployment rolls back, and you see repetitive restarts. Looking at the Pod events, you see the `livenessProbe` is consistently failing.
3.  **CI Pipeline Failure (GitHub Actions):** The Docker build step in Challenge 8's workflow fails with the error: `denied: requested access to the resource is denied`.

**Your Deliverable:**

For each of the three failure scenarios, provide:

1.  The **root cause** (1-2 sentences).
2.  The **most critical command(s)** you would execute to confirm or diagnose the issue in a real-world environment.

## Solution

1.  **Kubernetes Deployment Failure:**

**`Init: 0/1`**

If the state of my deployment is stuck in a state where new pods are created but they are stuck in **`Init: 0/1`** state it might be due to our init container is waiting for some external service or resource that is unavailable at the moment

Suppose we have following pod config
```yaml

apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-container
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]

```

here we have defined a container and an initcontainer but that initcontainer is waiting for another service to get available so that it can complete successfully but since we donot have any service it will keep on waiting and our pod will be in Init: 0/1 state



Note: we may get other types of errors as well 
- Init:ErrImagePull : when container is unable to pull the image
- Init:Error : when the init containers script failed to execute successfully


**`ImagePullBackOff`** 

If the state of the pod is showing as ImagePullBackOff then it could be because of following 2 reasons

- Wrong Image Name: In the config we might have specified the wrong image name and hence it is unable to pull the image
- Permission issue : The cluster does not have necessary permission to pull the image for example we have n;t logged into docker hub and trying to pull a private repo.


We can use the following commands to inspect the situation

- `kubectl describe pod <pod-name>` - we can use this commnad to check the status, errors and events

- `kubectl logs <pod-name> -c <container-name>` : to check the logs of containers running inside the pods


2. **Liveness Probe Failure:**

It might be due to 2 reasons

- insufficient initialDelaySeconds: Our app might be taking more time to start than the sepcified initalDelaySeconds and  liveness probe will be making request before it is ready to process the request causing the request to fail and pod restart

- unrealistic timeoutSeconds: We might have configure the timeoutSeconds too low which so before our request gets processed the liveness probe considers our pod to be unresponsive and restarts it


3. **CI Pipeline Failure (GitHub Actions):**  

this error might happen because of any either of the 2 reasons mentioned below 

1. we have our image stored in private repo and we have not logged into the docker hub and trying to access the image 
2. the dockerhub token which we have generated does not have required permissions to get/write the image from the repo.