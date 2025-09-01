**Kubernetes One-Click Deployment on AWS**

This project provisions a complete EKS (Elastic Kubernetes Service) infrastructure on AWS using Terraform, then deploys a full-stack application using Ansible and Jenkins CI/CD pipeline.

**Tools Used**

Terraform – Infrastructure provisioning (VPC, subnets, NAT GW, EKS cluster, etc.)

Ansible – Automates Kubernetes application deployment (attendance app)

Jenkins – CI/CD pipeline automation

kubectl – CLI to interact with the EKS cluster

AWS EKS – Managed Kubernetes cluster on AWS

AWS EC2 – Worker nodes managed by EKS

AWS CloudWatch – Monitoring and logging

Docker & GitHub – Image hosting and version control

**Project Overview**

Launched a production-ready EKS Cluster with private subnets across two AZs

Used Terraform to provision VPC, subnets, NAT Gateway, EKS, IAM roles, and node group

Used Ansible to deploy a custom attendance app on Kubernetes

**Jenkins pipeline automates:**

Terraform infra setup

Kubeconfig generation

Ansible app deployment

Application is exposed via a LoadBalancer service

Includes probes (readiness/liveness), resource limits, and AWS-integrated DNS

Monitoring is handled via CloudWatch logs and EKS metrics

**Directory Structure**
k8s-oneclick/
├── terraform/               # Infra provisioning
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
├── ansible/                 # App deployment via Ansible
│   ├── deploy-attendance.yaml
│   ├── attendance-deployment.yaml
│   ├── attendance-service.yaml
│   └── inventory.ini
├── Jenkinsfile              # CI/CD pipeline
└── README.md

**How It Works**

Jenkins pulls from GitHub and runs the pipeline

Terraform provisions EKS and networking on AWS

Jenkins updates kubeconfig locally

Ansible deploys the attendance app to the EKS cluster

LoadBalancer service exposes the app to the internet

CloudWatch provides logging and monitoring

You can access the app using the ELB DNS

**Features Implemented**

Multi-AZ EKS cluster with 2 worker nodes

Public/Private subnet segregation

LoadBalancer service for external access

Health checks (readiness & liveness probes)

Resource requests & limits

Automatic scaling config in EKS node group

CloudWatch logging for observability

YAML backup of all deployed resources for DR

**Backup & Disaster Recovery**

EBS snapshots available via AWS console

Manual resource backups:

kubectl get all --all-namespaces -o yaml > all-resources.yaml
kubectl get configmaps --all-namespaces -o yaml > configmaps.yaml
kubectl get secrets --all-namespaces -o yaml > secrets.yaml


EBS volumes can be snapshotted via console or automated backup policies

**Monitoring**

AWS CloudWatch is used to monitor:

EC2 instance metrics (CPU, Disk, etc.)

EKS cluster logs and events

Optionally, you can integrate Prometheus & Grafana

**Resources**

Terraform AWS Provider

Ansible Kubernetes Modules

AWS EKS Documentation

Kubernetes Official Docs
