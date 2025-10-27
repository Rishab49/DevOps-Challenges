# Challenge 6: Basic Kubernetes Deployment ⚓

## Objective
Transition your application from AWS EC2 Auto Scaling to a local, basic Kubernetes cluster using Minikube or Docker Desktop, introducing fundamental Kubernetes concepts.

This challenge combines Kubernetes, Docker, and Automation.

## The Scenario
The startup wants to explore migrating to Kubernetes for better resource utilization and portability. Your first task is to deploy your existing containerized application onto a local Kubernetes environment.

## The Challenge
The Application Manifest: Write the single YAML manifest file (deployment.yaml) needed to deploy the application. This file must contain the following two resources:

1. Deployment: A Kubernetes Deployment resource that creates 2 replicas of your web application container (using the image tag from previous challenges, e.g., rajrishab/challenge2:1.0).

2. Service: A Kubernetes Service resource that exposes the Deployment internally on Port 80 and uses the NodePort type to allow external access (mimicking public access from the internet).

3. Health Check & Readiness: Ensure the Deployment specifies a simple Liveness Probe and Readiness Probe that check the /health endpoint (using the HTTP GET method on the container port).

## Your Deliverable
Provide the complete, single YAML manifest file (deployment.yaml) for the application deployment.

You can assume you have a local Kubernetes cluster (like Minikube or Docker Desktop) running and your Docker image is locally available or pulled from the registry. Good luck!


## Solution

### Prerequisits

I have already created a docker image in previous challenges called `rajrishab/challenge2` with tag `1.8` and I'll use this image as container running inside pods in the cluster.

The Dockerfile of the image as follows

```Dockerfile
FROM httpd:2.4
RUN echo "<h1> It is working on $(hostname)" > /usr/local/apache2/htdocs/index.html
WORKDIR /usr/local/apache2/htdocs/health
COPY /health .
WORKDIR /usr/local/apache2/conf
COPY ./httpd.conf .
COPY ./server.conf .
RUN chmod a+x /usr/local/apache2/htdocs/
EXPOSE 80
```

we are using httpd base image and making few configuration changes and adding a health check endpoint `/health/`, the Dockfile along with config etc are present in the repo.


### 1. Deployment

After creating the image now we have to define our deployment config inside the deployments.yaml file as stated in the challenge statement.

I have created a deployment config with following properties:

```yaml
apiVersion: apps/v1 
kind: Deployment
metadata:
  name: my-app-deployment 
  labels: 
    app: Deployment # this label marks the deployment with label "Deployment", we can use the label for admin tasks
spec: 
  replicas: 2
  selector:
    matchLabels:
      app: deployment-pod # this label tells the Deployment it has to manage 2 replices to pods with label "deployment-pods"
  template:
    metadata:
      labels:
        app: deployment-pod # this label marks each pods with label "deployment-pod".
    spec:
      containers:
      - name: container
        image: rajrishab/challenge2:1.8
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "200m"
            memory: "64Mi"
          limits:
            cpu: "400m"
            memory: "128Mi"
```



In the above config our container will be running on port 80 but we cannot access it from outside as inside the pod it will be accessible on port 80.

In order to access it from outside we need to create a service


### 2. Service

I have created a service with following configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service 
  labels:
    app: service
spec:
  type: NodePort 
  selector:
    app: deployment-pod 
  ports:
    - protocol: TCP
      name: http-port 
      port: 80
      targetPort: 80 
      nodePort: 30080
```

It creates a service with label "service"(for admin purpose) and defines a nodePort i.e.,  a port through which we can access the service from outside. This nodePort uses TCP protocol and exposes 30080 port for external access.

Now our service has enabled us to access the service from outside our pod but we need a mechanism to check whether our container running inside the pod is ready to take traffics or not and also if it is working fine or not.


### 3. Health Check

Before creating health checks lets understand bit of theory

- Liveness probe - Liveness probe is a type of check which kubelet runs periodically to check whether the container is running fine or not. If it fails the probe then kubectl restarts the container.

We can define the port, endpoint, initialDelay and periodSeconds inside the pod config to let kubectl know which port and enpoint to make request and after certain amount of seconds repeatedly.


- Readiness probe - Readiness probe is a type of check which kubelet runs to check if a container is ready to accept traffic or not. If readiness probe fails then control plane will make sure it is not included in the pool of container which can accept the requests and it will run the probe periodically to check if container gets ready for the traffic or not.



I have updated the pod config like below

```yaml
    spec:
      containers:
      - name: container
        image: rajrishab/challenge2:1.8
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: "200m"
            memory: "64Mi"
          limits:
            cpu: "400m"
            memory: "128Mi"
        readinessProbe:
          httpGet:
            path: /health/
            port: 80
          initialDelaySeconds: 2
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /health/
            port: 80
          initialDelaySeconds: 2
          periodSeconds: 5
```

with livenessProbe on port 80 and endpoint /health/ with initaiDelay of 2 seconds and periodic checks on every 5 seconds. Same for readinessProbe

