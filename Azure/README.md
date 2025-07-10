# 🟦 Azure Deployment for MetaDefender (Core / ICAP / Storage Security)

This folder contains Terraform and scripts to deploy **MetaDefender** on Azure using either a single VM or an auto-scaling **Azure Virtual Machine Scale Set (VMSS)**.

## 📁 Folder Structure

- `single-vm-deployment/` – Terraform project for deploying a **single VM** running MetaDefender Core or Storage Security.
- `vm-scale-set-deployment/` – Terraform project for deploying a **VMSS** with MetaDefender, ideal for production environments requiring auto‑scaling and high availability.
- `azure-terraform-modules/` – Terraform modules for deploying a all the resources needed for MetaDefender.
- `function_project/` – Azure Function code examples to handle the licensing automation for the MetaDefender products
- `README.md` – This file.

## ⚙️ Prerequisites

- Azure subscription with permission to create VMs, networking, VMSS, resource groups.
- [Terraform](https://www.terraform.io/) v1.x installed.
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) configured locally.

## 🚀 Deployment Scenarios

### 1. Single VM
Best suited for development, testing, or simple production use.  
Uses MetaDefender Core image from [Azure Marketplace]()

### 2. VMSS (Virtual Machine Scale Set)
Recommended for enterprise production setups needing:
- Auto-scaling
- Redundancy and high availability
- Consistency via a shared VM image
Guided by the "VM Scale Set – MetaDefender Core" deployment [instructions](https://www.opswat.com/docs/mdcore/cloud-deployment/vm-scale-set-deployment?utm_source=chatgpt.com)

## 📘 Usage Guide

### 🟦 Single VM

```bash
cd single-vm-deployment/
# Update terraform.tfvars: VM_PWD, LICENSE_KEY_CORE, LICENSE_KEY_ICAP and the flags for each product to deploy
terraform init
terraform plan
terraform apply
```

Once deployed, retrieve the public IP and access the MetaDefender Core web portal.

### 🔁 VMSS (Virtual Machine Scale Set)

```bash
cd vmss/
# Update terraform.tfvars: VM_PWD, LICENSE_KEY_CORE, APIKEY and the flags for each product to deploy
terraform init
terraform plan
terraform apply
```

### 🔄 Updating Deployments
- Single VM: change VM size or image version, then reapply.
- VMSS: update image reference or auto-scaling settings, then run terraform apply.

### 🔐 Licensing
- Requires proper MetaDefender licenses.
- For VMSS setups, license activation can be integrated
      - (Only POC) Using API keys and startup scripts in the VM image of the Marketplace
      - (Production) Using Azure function trigger based on VM event. See code under `function_project/event_licensing_handler`

### 🤝 Contributing
Contributions are welcome:

- Fork the repo.
- Create a branch: feature/azure-vmss-enhancement.
- Implement changes, test locally.
- Commit, push, and open a pull request.
- Use “enhancement” as a label.

### 📄 References
- VM Scale Set – MetaDefender Core deployment guide [instructions](https://www.opswat.com/docs/mdcore/cloud-deployment/vm-scale-set-deployment?utm_source=chatgpt.com)
- Single Azure VM – MetaDefender Core guide [instructions](https://www.opswat.com/docs/mdcore/cloud-deployment/single-azure-vm?utm_source=chatgpt.com)
