# Automated CI/CD Pipeline for a Static Website on AWS

![GitHub](https://img.shields.io/github/license/srijato-05/AWS-Cloud-DevOps-CI-CD) ![Build](https://img.shields.io/badge/Build-Passing-brightgreen) ![Deployment](https://img.shields.io/badge/Deployment-EC2-orange)

This repository contains the complete Infrastructure as Code (IaC) and application source for deploying a static website, "The Curator's Compendium," to an Amazon EC2 instance using a fully automated CI/CD pipeline. The entire infrastructure is provisioned via **AWS CloudFormation**, and the pipeline is orchestrated by **AWS CodePipeline**, integrating with **AWS CodeBuild** and **AWS CodeDeploy**.

The primary goal is to establish a GitOps workflow where a `git push` to the main branch automatically triggers the deployment of the latest version of the website with no manual intervention.

---

## Architecture Overview

The pipeline is designed for efficiency and automation, following a standard three-stage workflow.

1.  **Source Stage**: An **AWS CodeStar Connection** securely links AWS CodePipeline to a designated GitHub repository and branch. A `git push` event initiates the pipeline, which pulls the source code into an S3 artifact store.
2.  **Build Stage**: **AWS CodeBuild** is triggered, using an Amazon Linux 2 container environment. It executes the commands defined in `buildspec.yml`, which involves setting script permissions and packaging all repository files into a build artifact.
3.  **Deploy Stage**: **AWS CodeDeploy** receives the build artifact and manages the deployment to a group of EC2 instances tagged with `App: CuratorCompendium`. The CodeDeploy agent on the instance follows the instructions in `appspec.yml` to execute a series of lifecycle hooks for a safe, in-place deployment.
