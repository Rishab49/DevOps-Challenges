# Challenge 14: Stateful Application Management with Volumes 💾
## Objective: 
Introduce stateful application management by creating a Kubernetes StatefulSet and defining its persistent storage requirements using a PersistentVolumeClaim (PVC).

This challenge focuses on Stateful Applications, Data Persistence, and Volume Management.

## The Scenario
Your application now requires a simple key-value store (like Redis) that needs to ensure two things:

Stable Network Identity: Each replica must maintain a unique, predictable identity (e.g., redis-0, redis-1).

Persistent Storage: Data must survive Pod restarts and rescheduling.

## The Challenge
Write a single YAML manifest (stateful-redis.yaml) that defines the following resources:

Headless Service: A Service named redis-headless that a) does not have a ClusterIP and b) targets the Pods created by the StatefulSet.

StatefulSet: A StatefulSet named redis-statefulset with:

replicas: 2.

The use of the redis-headless Service.

A container using the image redis:6.2.6-alpine on container port 6379.

PersistentVolumeClaim Template: Define a volumeClaimTemplates block requesting a 1Gi volume named redis-data. Assume a default storageClass is configured.

## Your Deliverable: 
The complete, single YAML manifest file (stateful-redis.yaml) defining all three resources.

## Solution


I have created a headless service using the below config
```yaml

apiVersion: v1
kind: Service
metadata:
  name: redis-headless
spec:
  #type: ClusterIP
  clusterIP: None
  selector:
    app: redis
  ports:
    - port: 6379
      targetPort: 6379

```

here we haven't defined any service type because by default kubernetes will consider a service as headless


then I have created a statefulset using below config

```yaml


apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  selector:
    matchLabels:
      app: redis
  serviceName: redis-headless
  replicas: 2
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: redis:6.2.6
          ports:
            - name: redis
              containerPort: 6379
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi

```

in the above config along with stateful set we have defined a volumeClaimTemplate which will dynamically create a volume for the pod and it is managed as part of stateful sets lifecycle




Conceptual Question
What is the primary use case of a Headless Service when used in conjunction with a StatefulSet, and why is a standard ClusterIP Service often insufficient for managing stable network identities in this scenario?

Ans: The primary use of headless service is to allow the pods to communicate with each other and external services to discover and connect to individual pods.

standard clusterip is insufficient for managing stable network indentities because clusterip based services acts as load balancers which routes traffic to different services depending on the load, hence creating a stable connecting between client and a specific pod is not possible.

Practical Scenario Question
A Pod in your newly created StatefulSet is stuck in the Pending state, and running kubectl describe pod <pod-name> reveals an error similar to 0/2 nodes are available: 2 persistentvolumeclaims "redis-data-redis-statefulset-0" not found.

What is the single, immediate troubleshooting step you must take on the StatefulSet resource itself to confirm the existence of the missing PersistentVolumeClaim (PVC)? (Assume the manifest was applied correctly.)


Ans: to discover pvc's defined inside a cluster we can use `kubectl get pvc -l app=redis` to check whether pvc's are defined or not

if the PVCs are created but stuck in pending state then it is the issue with underlying storageclass which is not able to provision the storage.