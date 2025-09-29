# Automated CI/CD Pipeline for a Static Website on AWS

![GitHub](https://img.shields.io/github/license/srijato-05/AWS-Cloud-DevOps-CI-CD) ![Build](https://img.shields.io/badge/Build-Passing-brightgreen) ![Deployment](https://img.shields.io/badge/Deployment-EC2-orange)

This repository contains the complete Infrastructure as Code (IaC) and application source for deploying a static website, "The Curator's Compendium," to an Amazon EC2 instance using a fully automated CI/CD pipeline. The entire infrastructure is provisioned via **AWS CloudFormation**, and the pipeline is orchestrated by **AWS CodePipeline**, integrating with **AWS CodeBuild** and **AWS CodeDeploy**.

The primary goal is to establish a GitOps workflow where a `git push` to the main branch automatically triggers the deployment of the latest version of the website with no manual intervention.

---

## Architecture Overview

This diagram illustrates the end-to-end continuous integration and deployment pipeline.

```mermaid
graph LR
    subgraph "CI/CD Workflow"
        Developer -- "git push" --> GitHub[GitHub Repo]
        GitHub --> CodePipeline[AWS CodePipeline]
        CodePipeline -- "Source Stage" --> CodeBuild[AWS CodeBuild]
        CodeBuild -- "Build Stage" --> S3[(Artifact Store)]
        S3 -- "Deploy Stage" --> CodeDeploy[AWS CodeDeploy]
        CodeDeploy -- "Sends instructions" --> Agent[CodeDeploy Agent]
        Agent -- "Executes hooks on" --> EC2[EC2 Instance <br/> Apache Server]
    end

---

### Explanation

* A **Developer** pushes code changes to a **GitHub Repo**.
* The push triggers **AWS CodePipeline**, which pulls the source code.
* **AWS CodeBuild** takes the source, prepares a build artifact as defined in `buildspec.yml`, and stores it in an S3 bucket.
* **AWS CodeDeploy** picks up the artifact from S3 and initiates a deployment to the target EC2 instance(s).
* The **CodeDeploy Agent** running on the EC2 Instance receives the deployment instructions and manages the process locally by executing the lifecycle hook scripts (`stop_server.sh`, `start_server.sh`, etc.) defined in `appspec.yml`.

---

## Core Configuration Files

The behavior of the pipeline and infrastructure is defined by several key YAML files.

* ### `cloudformation_template.yml`
    This is the master template that provisions all AWS resources. It creates the EC2 server, all required IAM roles, the S3 artifact bucket, security groups, and the full CodePipeline with its constituent stages.

* ### `appspec.yml`
    The Application Specification File dictates the deployment logic for the CodeDeploy agent on the EC2 instance.
    * **`files`**: Maps source files (`index.html`, `style.css`) and the `images` directory to the Apache web root `/var/www/html`.
    * **`hooks`**: Defines the sequence of scripts to be executed at specific points in the deployment lifecycle.

* ### `buildspec.yml`
    The Build Specification File provides instructions to AWS CodeBuild.
    * **`install` phase**: Sets execute permissions on all deployment hook scripts.
    * **`build` phase**: As this is a static site, no compilation is needed. This phase simply prepares the files for artifacting.
    * **`artifacts`**: Specifies that all files (`**/*`) from the source should be included in the output artifact.

---

## Deployment Lifecycle Hooks

CodeDeploy ensures a robust deployment process by executing a series of scripts defined in `appspec.yml`. This sequence provides for a clean installation and service validation.

* **`ApplicationStop`**: The `stop_server.sh` script is executed to gracefully stop the `apache2` service.
* **`BeforeInstall`**: The `before_install.sh` script runs, which completely clears the contents of the `/var/www/html` directory to prevent stale files.
* **`Install`**: The CodeDeploy agent copies the new application files from the artifact to `/var/www/html`.
* **`ApplicationStart`**: The `start_server.sh` script starts the `apache2` service.
* **`ValidateService`**: The `validate_service.sh` script performs a health check by running `curl -f http://localhost/`. The `-f` flag ensures that `curl` will exit with an error code if it receives an HTTP failure (like 4xx or 5xx), which signals a failed deployment to CodeDeploy, automatically triggering a rollback.

---

## Prerequisites

To deploy this project, you must have the following:

* An **AWS Account** with sufficient permissions to create IAM roles and the other resources defined in the template.
* A **GitHub Account** and a repository containing the code from this project.
* An **AWS CodeStar Connection** to your GitHub account configured in the same AWS region as your deployment. This is a one-time setup that authorizes AWS to access your repositories.

---

## Step-by-Step Deployment Guide

### 1. Configure the CodeStar Connection

1.  Navigate to the **AWS Developer Tools console** -> **Settings** -> **Connections**.
2.  Create a new connection, select **GitHub**, and authorize it with your GitHub account.
3.  Once the connection status is **Available**, copy its **ARN**.

### 2. Launch the CloudFormation Stack

1.  Navigate to the **AWS CloudFormation** console and click **Create stack**.
2.  Select **Upload a template file** and choose `cloudformation_template.yml`.
3.  Enter a stack name (e.g., `Curator-Compendium-Pipeline`).
4.  Fill in the **Parameters** section:
    * `GitHubRepoName`: Your repository name in the format `YourUsername/YourRepoName`.
    * `GitHubBranchName`: The branch to trigger deployments from (e.g., `main`).
    * `CodeStarConnectionArn`: The full ARN you copied in the previous step.
5.  Acknowledge that IAM resources will be created and launch the stack.

### 3. Verify Deployment

* The stack creation will take a few minutes. Once complete, the CodePipeline will automatically trigger its first execution.
* Navigate to **AWS CodePipeline** to monitor the progress through the Source, Build, and Deploy stages.
* Once the pipeline succeeds, go to the **Outputs** tab of your CloudFormation stack and find the `InstancePublicIp` value. Open this IP address in a web browser to see your deployed website.

---

## Technical Specifications

* **EC2 Instance**: The pipeline deploys a `t2.micro` instance running **Ubuntu Server 22.04 LTS** in the `ap-south-1` region. The `UserData` script handles the bootstrapping of Apache2 and the CodeDeploy agent.
* **Security Group**: The instance is protected by a security group that allows inbound traffic on **Port 80 (HTTP)** and **Port 22 (SSH)** from any IP address (`0.0.0.0/0`).
* **Debugging Infrastructure**: A separate template, `infrastructure-only.yml`, is provided for debugging purposes. It provisions only the EC2 instance and its roles, using an **Amazon Linux 2** AMI and `httpd` instead of Ubuntu/Apache2.
