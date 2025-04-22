# Container Security Challenge

Welcome to the Container Security Challenge! You're a DevSecOps engineer tasked helping with a customer PoC/Demo. Your goal is to set up a Kubernetes cluster, deploy containerized apps, enforce security policies, and investigate runtime violations. This challenge is hands-on and designed to test your skills in Kubernetes, Helm, and container security. Expect to struggle, troubleshoot, and learn by diving into documentation.

> **Note**: Instructions are intentionally high-level. Use official documentation for Kubernetes, Helm, and the provided container security tool to complete tasks. Success depends on your ability to explore, debug, and verify.

## Prerequisites

- Familiarity with Kubernetes (pods, namespaces, RBAC)
- Basic knowledge of Helm for deploying applications
- Access to a terminal with kubectl, helm, and the container security tool's CLI (details provided in Task 2)
- (Optional) AWS CLI and credentials if deploying the cluster yourself

## Challenge Tasks

### Task 1: Set Up the Kubernetes Cluster and create application namespaces

FinSecure needs a test Kubernetes cluster to host its applications. You have two options:

- **Option A**: Use the provided CloudFormation template (cloudformation.yaml) to deploy an EKS cluster in your AWS account. Deploy the template, retrieve the kubeconfig, and verify access.
- **Option B**: Build your own cluster however you want with EKSCTL and CLI.

**Objective**:
- Gain access to the cluster
- Verify connectivity with `kubectl get nodes`
- Create application namespaces in the cluster:
  - Namespace #01: backend
  - Namespace #02: frontend

### Task 2: Setup TMAS locally on your computer

As per the POC requirements for container scanning we need to showcase the ability to scan containers and later enforce a policy against these scanned container images.

1. Install the Trend Micro Artifact scanner on your local computer:
   - Documentation: https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-install-artifact-scanner

### Task 3: Scan the Frontend (nginx) Image using TMAS

Before deploying the nginx image, FinSecure requires all images to be scanned for vulnerabilities, secrets and malware using the TMAS scanner (part of the security tool).

**Objective**:
- Scan the nginx:latest image using the TMAS CLI
- Save the scan results (e.g., JSON format)

**Links**
- https://hub.docker.com/_/nginx

### Task 4: Setup a policy for deployment

FinSecure Global is looking to test a couple scenarios with our container security, so we will need to create one policy with settings for two different namespaces. Follow the instructions below to create and configure these two set of settings in the policy.

#### Policy Requirements:

**Part A**: 
Create a policy under container protection called `finsecure_testing` and then in the settings below find the section for "Kubectl Access" and make sure these are the only two settings enabled in this policy:

1. BLOCK: "attempts to execute in/attach to a container"
2. LOG: "attempts to establish port-forward on a container"

**Part B**:
In the same policy add another namespace to this policy using the plus button next to "Policy Definitions" and call the NAMESPACE "backend":

1. BLOCK: "images that have not been scanned for malware in the last 30 days"
2. BLOCK: "images that have not been scanned for malware in the last 30 days"
3. BLOCK: "images that have not been scanned for secrets in the last 30 days"

**Part C**:
In this policy there is a section for runtime. Please create a runtime rule list and include the following rules to this policy:

- Isolate: (T1552)Search Private Keys or Passwords
- Terminate: (T1552.001)Find AWS Credentials
- Log: (T1552.005)Contact EC2 Instance Metadata Service From Container
- Log: (T1505)Update Package Repository

### Task 5: Install the Container Security Tool and apply policy

FinSecure Global wants to use Trend's Vision One container security tool to enforce policies and scan images. These tools need to be installed using Helm. Follow the instructions from the documentation to deploy.

**Objective**:
- Deploy Vision One Container Security
- Verify deployment by checking namespace

**Links**:
- https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-eks-clusters-without-fargate

### Task 6: Deploy Application Containers

FinSecure Global runs two applications in separate namespaces. You'll deploy busybox into the backend namespace.

**Objective**:
- Deploy nginx:latest in the frontend namespace
- Deploy busybox:latest in the backend namespace (this might fail check logs in console or CLI for reason)
- Verify both pods are running (if you get failures check the logs/console)

**Links**:
- https://hub.docker.com/_/nginx
- https://hub.docker.com/_/busybox/

### Task 7: Trigger Runtime Security Rules on the Nginx container

FinSecure monitors containers for suspicious activity. You'll simulate malicious behavior in the nginx container to trigger runtime security rules.

**Objective**:
- Use kubectl exec to access the nginx pod (check console for logs)
- Perform actions to trigger security rules (search for secrets, using a network tool like nmap or netscan)

### Task 8: Check Container Security Logs

The last thing the customer wants from us is to understand how they will get logs from our container security solution. They want to create an automated process for this if something were to go wrong in the future. Let's give them a couple examples of how we can check our container security logs.

**Links**:
- https://docs.trendmicro.com/en-us/documentation/article/trend-vision-one-container-security-faqs

