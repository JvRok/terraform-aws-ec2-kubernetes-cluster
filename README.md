# Kubernetes Terraform EC2 Example

This repo is created to flesh out my understanding of Kubernetes + Terraform through creating a basic K8s cluster using AWS elements + EC2

<!-- TOC -->

- [AWS Kubernetes](#aws-kubernetes)
  - [Updates](#updates)
  - [Description](#description)
  - [Dependencies and Setup](#dependencies-and-setup)
  - [Notes](#notes)
  - [Planned Changes](#planned-changes)

<!-- /TOC -->

## Updates

- *2022.07.11* Readme + Initial Controller EC2 Instance

## Description

*Why not use the EKS?*
I would generally use EKS on AWS, but the purpose of this module is to explore all of K8s, Rough Edges includes. Possibly as a basis for further exploration of Kubernetes in the future.

## Dependencies and Setup

- VPCs + Subnets already created. These will be defaulted out in the repo.
- Login Keys for Servers need to exist on AWS, name the key you want in the variables after.

## Notes

With the stated goal of this module being a learning experience, this section contains the a changing high-level detail of k8s setup with terraform and any relevant/useful details.

## Planned Changes

- *Provision EC2 Controller Node*
  - Pre-requisite setup
  - Kubeadm based installation
  - output variables for other node's setups
  - *Install basic CNI*
    - Calico as it supports ingress
- *Setup n amount of worker nodes*
  - Requires output vars from controller
  - Setup with kubeadm
  - Join with kubeadm string
- *Open up security groups*
  - Requires output vars from controller + workers
  - Auto create the groups and add workers/masters.

- *Demo basic webapp on module*
- *Final Change:*
  - Make the module instantiable (e.g. populated example folder, take out hardcoded dependencies that makes this personal rather than templated).
