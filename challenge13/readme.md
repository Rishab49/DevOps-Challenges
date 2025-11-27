## Challenge 13: Cost Optimization and FinOps 💰
## Objective: 
Apply financial operations (FinOps) principles to your deployed infrastructure to demonstrate an understanding of controlling cloud costs, a critical skill for any DevOps role.

## The Scenario
Your manager notices that the EKS cluster (where your application would run in a real cloud environment) costs are unexpectedly high. They ask you to review the resource requests and limits in your Kubernetes Deployment (web-app-deployment) from Challenge 6.

Original Requests: cpu: "200m", memory: "64Mi"

Original Limits: cpu: "400m", memory: "128Mi"

After monitoring the Pods during peak load, you discover the application rarely uses more than 30m (30 millicores) of CPU and 40Mi of memory.

## The Challenge
Cost-Saving Strategy: Identify which of the two resource settings (requests or limits) has the direct and immediate impact on cloud billing for your EKS cluster worker nodes, and explain why.

Recommendation: Based on the new peak usage data, what are the new recommended values for resources.requests (CPU and Memory) that minimize cost without risking service downtime?

HPA Impact: Briefly explain (1-2 sentences) how lowering the CPU Request value impacts the behavior and cost of the Horizontal Pod Autoscaler (HPA) configured in Challenge 7.

## Your Deliverable:

The resource setting impacting cost and the explanation.

The new recommended CPU and Memory request values.

The HPA impact explanation.


## Solution

1. Cost-Saving Strategy: Kubernetes `requests` setting has the direct and immediate impact on the cloud billing because it specifies the minimum amount of resource reserved for a container, so if we set cpu = 2 and memory = 1GiB then in that case 2 core of cpu and 1 gb of RAM will be allocated for the container immediately impacting the cloud bill.


2. Recommendation: Since monitoring suggests that container does not use more than 30m CPU and 40Mi of memory then we can set 

```yaml


resources:
    requests:
        cpu: "20m"
        memory: "30Mi"
    limits:
        cpu: "40m"
        memory: "50Mi"


```

3. HPA Impact: If we lower the cpu request value of container then in that case average utilization of container will high in that case if we have set target avrage utilization to 50 then pod will auto scale more often.