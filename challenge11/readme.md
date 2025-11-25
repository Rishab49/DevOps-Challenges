# Challenge 11: Application Configuration with ConfigMaps and Secrets 🔐

## Objective: 
Securely manage application settings and environment-specific variables using native Kubernetes methods.

## The Scenario
Your web application needs a configuration flag (APP_MODE=production) and a secure API key (INTERNAL_API_KEY). Currently, these might be hardcoded in the Dockerfile or the Deployment manifest. You need to pull them out into dedicated Kubernetes objects.

## The Challenge
Write a single YAML manifest (config.yaml) that defines two Kubernetes objects to achieve this:

ConfigMap: An object named app-config that stores the configuration key-value pair: APP_MODE: "production".

Secret: An object named api-key-secret that securely stores the API key: INTERNAL_API_KEY: "supersecretkey123". (Note: All Secret data values must be Base64 encoded, though Kubernetes handles the decoding on the Pod.)

Then, demonstrate how to inject both the environment variable (APP_MODE) from the ConfigMap and the secret key (INTERNAL_API_KEY) from the Secret into the web-app-container of your existing Deployment using the envFrom method (for the ConfigMap) and the valueFrom method (for the Secret).

## Your Deliverable:

The complete, single YAML manifest file (config.yaml) containing both the ConfigMap and the Secret.

The YAML snippet showing the spec.containers block of the Deployment, demonstrating the correct environment variable injection.


## Solution

**ConfigMap**

We can create ConfigMap in kubernetes using the following config

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: demo-config
data:
  hostname: "machine1"
  ip: "192.168.1.1"


```


here we have created a simple ConfigMap with 2 values `hostname` and `ip`, which we are using the inside the pod's container using `$(ENV_VAR_KEY)` notation.



**Secrets**

We can create secrets using the following config


```yaml

apiVersion: v1
kind: Secret
metadata:
  name: demo-secret
type: Opaque
data:
  username: YWRtaW4=
  password: cGFzc3dvcmQ=

```

here we have created a simple config with value username and password, which we are using inside the container using `$ENV_VAR_KEY` notation.


Inside the container we can use the secrets and configmap values as shown below

```yaml

apiVersion: v1
kind: Pod
metadata: 
  name: demo-pod
spec:
  containers:
    - name: app
      command: ["/bin/sh","-c","echo '$(hostname)'; echo $USERNAME"]
      image: busybox:latest
      envFrom: 
       - configMapRef:
            name: demo-config
      env:
        - name: USERNAME
          valueFrom:
            secretKeyRef:
              name: demo-secret
              key: username

```