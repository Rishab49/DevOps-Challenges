# Challenge 8: Continuous Integration (CI) with GitHub Actions ⚙️


# Objective
Automate the Docker build, test, and push process using a modern CI tool, specifically GitHub Actions.

This challenge focuses on CI/CD, Docker, and Security (Secrets Management).

## The Scenario
The startup has adopted GitHub for all source code. They need a pipeline that automatically builds the application's Docker image, tags it reliably, and pushes it to Docker Hub every time a developer merges code into the main branch.

## The Challenge

- GitHub Actions Workflow: Write a complete GitHub Actions Workflow YAML file (.github/workflows/docker-build-push.yml) that triggers on a push to the main branch.

- Image Tagging: The image must be tagged using the short Git commit SHA (the first 7 characters of github.sha) to ensure a unique and traceable version number for every build.

- Secure Push: The workflow must securely log in and push the newly built image to Docker Hub using placeholders for the necessary GitHub Secrets.

- Assumed image name: rajrishab/challenge2 (from previous challenges).

- Test Step (Conceptual): Include a placeholder step where the application would run unit tests or security scans before the final push.

## Your Deliverable

Provide the complete, single GitHub Actions Workflow YAML file (docker-build-push.yml).

This is one of the most common interview and real-world tasks for a DevOps engineer. Good luck!

## Solution
