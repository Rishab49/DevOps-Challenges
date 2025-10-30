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

In this challenge we have to write a github action which will build and push our image to docker hub when we push our docker image code on main branch

In order to acheieve this goal we need to create a workflow file inside `.github/workflows/workflow.yaml`

The workflow file needs to perform following tasks in sequence to achieve the goal

1. Login to dockerhub
2. create the 7 character long tag for the image
3. checkout the repository to build the image using the Dockerfile
4. Bulding and Pushing the image to dockerhub




1. To login to dockerhub we need a github action called `docker/login-action@v3` and yaml config will look like this
```yaml
- name: DockerHub login
        uses: docker/login-action@v3
        with:
          username: ${{ vars.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
```

here we have used the DOCKER_USERNAME variable and DOCKER_PASSWORD secret which we can define in our repository bu navigating to the settings page

2. next we have to prepare the 7 character long image tag, we which we can prepare using the following step

```yaml
 - name: Get tag
        id: get-tag
        run: echo "id=$(echo ${{github.sha}} | cut -c 1-7)" >> "$GITHUB_OUTPUT" |
             echo "tag=$id"
```


here we are creating a substring i.e, 7 character  long and saving that value as id inside the output context variable so that we can use that value in order steps.


3. checkout the repo
Now we  need to checkout the repo meaning copying the source code of the repo in the VM which we are using to build the image
```yaml
- name: Checkout
        uses: actions/checkout@v2
```


4. Building and pushing the image
Finally we can build and push our image using `docker/build-push-action@v6` action which uses the output from previous build steps and another repo variable called `IMAGE_NAME`. 

```yaml
- name: Build and push
        uses: docker/build-push-action@v6
        with:
          push: true
          context: ./challenge8/docker
          file: ./challenge8/docker/Dockerfile
          tags: ${{ vars.DOCKER_USERNAME}}/${{ vars.IMAGE_NAME }}:${{ steps.get-tag.outputs.id }}
```



Workflow YAML file

```yaml
name: Building Docker image and pushing to DockerHub
run-name: ${{ github.actor }} is Building and pushing an image
on:
  push:
    branches: ['main']
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: DockerHub login
        uses: docker/login-action@v3
        with:
          username: ${{ vars.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      - name: Get tag
        id: get-tag
        run: echo "id=$(echo ${{github.sha}} | cut -c 1-7)" >> "$GITHUB_OUTPUT" |
             echo "tag=$id"
      - name: Checkout
        uses: actions/checkout@v2
      - name: Build and push
        uses: docker/build-push-action@v6
        with:
          push: true
          context: ./challenge8/docker
          file: ./challenge8/docker/Dockerfile
          tags: ${{ vars.DOCKER_USERNAME}}/${{ vars.IMAGE_NAME }}:${{ steps.get-tag.outputs.id }}
```

