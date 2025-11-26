# Challenge 12: Advanced Networking and Ingress 🌐
Objective: Introduce an Ingress resource to manage external access, replacing the basic NodePort service and enabling path-based routing.

## The Scenario
Your current NodePort Service works, but it exposes the application on a high, random port (or port 30080) and doesn't handle proper routing or SSL termination. You need to transition to an Ingress object to manage external HTTP/S access via a standard web address.

Assume you have an Ingress Controller (like NGINX Ingress Controller) already running in your cluster.

## The Challenge
Write a single YAML manifest (ingress.yaml) that defines an Ingress resource for your application based on the following rules:

Host and Name: The Ingress should be named web-app-ingress and handle traffic for the host app.example.com.

Service Mapping: It must route all traffic coming to app.example.com to the Service you created in Challenge 6 (web-app-service) on port 80.

Path Routing: Implement two distinct path rules:

Requests to the root path (/) should be directed to the web-app-service.

Requests to the path /admin should be directed to a separate, conceptual service named admin-service (also on port 80).

## Your Deliverable: 
The complete, single YAML manifest file (ingress.yaml) for the Ingress resource.

## Solution

In order to create an ingress we need to create a service pointing to a deployment running inside a container inside a pod using a config something like follwing

```yaml

apiVersion: v1
kind: Service
metadata:
  name: web-app-service
spec:
  type: NodePort
  selector: 
    app: my-deployment
  ports:
    - port: 80
      nodePort: 30080
      targetPort: 80

```


also we need a deployment which this service's nodePort refer to 
```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
 name: my-deployment
spec:
 replicas: 1
 selector:
   matchLabels:
     app: my-deployment
 template:
   metadata:
     labels:
       app: my-deployment
   spec:
     containers:
     - name: my-container
       image: challenge12:latest
       imagePullPolicy: IfNotPresent
       ports:
       - containerPort: 80

```


lastly we can create our ingress pointing to the services which we have created providing it DNS using configuration smoething like below

```yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
 name: my-ingress
spec:
 rules:
 - host: app.example.com
   http:
     paths:
     - pathType: Prefix
       path: "/"
       backend:
         service:
           name: web-app-service
           port:
             number: 80
     - pathType: Prefix
       path: "/admin"
       backend:
        service:
          name: admin-service
          port:
            number: 80

```