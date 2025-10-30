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

###  GitHub Actions CD Script:


