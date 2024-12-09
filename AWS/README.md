# AWS CSP Automations #

This folder contains the different options to create AWS resources, using Terraform, needed to deploy MetaDefender Core, MetaDefender ICAP Server and Metadefender Storage Security

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#supported-deploymnet-options-per-product">Supported Deployment Options per Product</a>
    </li>
    <li>
      <a href="#prerequisites">Prerequisites</a>
    </li>
    <li><a href="#licensing-management-options">Licensing management options</a></li>
    <li><a href="#database-configuration-options">Database configuration options</a></li>
    <li><a href="#setting-up-deployment-variables">Setting up deployment variables</a></li>
    <li><a href="#deploying-resources">Deploying resources</a></li>
    <li><a href="#how-to-run-tests">How to run tests</a></li>
    <li><a href="#destroying-resources">Destroying resources</a></li>
  </ol>
</details>

## Supported Deployment Options per Product

This terraform project supports 2 types of deployments in AWS

- Single EC2 instance (MetaDefender Core, MetaDefender ICAP Server and MetaDefender Storage Security)
- AutoScaling Groups (MetaDefender Core and MetaDefender ICAP Server)

<p align="right">(<a href="#top">back to top</a>)</p>

## Prerequisites

- [Terraform installed](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS credentials set up for Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)

<p align="right">(<a href="#top">back to top</a>)</p>

## Licensing management options

It is needed an activation for each MetaDefender instance deployed. There are 2 ways to manage the license automatically

- Passing the LICENSE_KEY and APIKEY through environment variables to each of the instances (Supported in single EC2 and Autoscaling deployments, set them up in terraform.tfvars of each deployment type folder)
- Triggering a Lambda function based on AutoScaling group events. (Supported for Autoscaling deployments of MetaDefender Core and MetaDefender ICAP Server)

<p align="right">(<a href="#top">back to top</a>)</p>

## Database configuration options

All the MetaDefender products are deployed using a local database for each instance deployed. 

<p align="right">(<a href="#top">back to top</a>)</p>

## Setting up deployment variables

Go to the terraform.tfvars of each deployment folder (single-ec2 or autoscaling-group)

<p align="right">(<a href="#top">back to top</a>)</p>

## Deploying resources

`terraform apply`

<p align="right">(<a href="#top">back to top</a>)</p>

## Destroying resources

`terraform destroy`

<p align="right">(<a href="#top">back to top</a>)</p>
