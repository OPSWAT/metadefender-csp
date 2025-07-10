import logging
import os
import json
import requests
import time

import azure.functions as func
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient

# Global clients
credential = DefaultAzureCredential()
subscription_id = os.getenv("SUBSCRIPTION_ID")
if not subscription_id:
    raise ValueError("Environment variable 'SUBSCRIPTION_ID' is required but not set.")

key_vault_name = os.getenv("KEY_VAULT_NAME")
if not key_vault_name:
    raise ValueError("Environment variable 'KEY_VAULT_NAME' is required but not set.")

vault_url = f"https://{key_vault_name}.vault.azure.net"
secret_client = SecretClient(vault_url=vault_url, credential=credential)
compute_client = ComputeManagementClient(credential, subscription_id)
network_client = NetworkManagementClient(credential, subscription_id)

ACTIVATION_SERVER_URL = "https://activation.dl.opswat.com"

def main(event: func.EventGridEvent):
    logging.info("Event Grid trigger received")
    
    try:
        logging.info("Event: %s", event.event_type)
        data = event.get_json()
        op = data.get("operationName")
        rt = data.get("resourceProvider")
        logging.info("Event Data: %s", data)
        logging.info("Event Operation Name: %s", op)
        logging.info("Event Resource Type: %s", rt)
    except Exception as e:
        logging.error("Invalid JSON payload: %s", e)
        return

    # Extract the VM resource ID
    resource_id = data.get("resourceUri")
    logging.info("resource_id: %s", resource_id)
    
    # Example resource ID: /subscriptions/xxx/resourceGroups/rg-name/providers/Microsoft.Compute/virtualMachines/vm-name
    try:
        parts = resource_id.split("/")
        rg_name = parts[4]
        vm_name = parts[-1]
        logging.info("Parsed resource group: %s, VM name: %s", rg_name, vm_name)
    except Exception as e:
        logging.error("Failed to parse VM info from resourceId: %s", e)
        return

    # Detect action from event.subject or event.event_type
    event_type = event.event_type.lower()
    logging.info("Event type: %s", event_type)

    secrets = load_secrets()
    if not secrets:
        return func.HttpResponse("Failed to load secrets", status_code=500)

    core_user = secrets["coreUser"]
    core_pwd = secrets["corePwd"]
    license_key = secrets["licenseKey"]
    apikey = secrets["apiKey"]

    try:
        if rt == "Microsoft.Compute":
            if op == "Microsoft.Compute/virtualMachines/start/action":
                logging.info("VM started")
                vm_ip = get_vm_ip(rg_name, vm_name)
                if not vm_ip:
                    return func.HttpResponse("No IP for VM", status_code=502)

                if not apikey:
                    if not core_pwd:
                        core_pwd = get_vm_id(rg_name, vm_name)
                    apikey = get_session_id(vm_ip, core_user, core_pwd)
                    if not apikey:
                        return func.HttpResponse("Auth failed", status_code=502)

                if activate_license(vm_ip, license_key, apikey, vm_name):
                    store_deployment_id(vm_ip, apikey, vm_name)
            elif op in ["Microsoft.Compute/virtualMachines/deallocate/action", "…/powerOff/action"]:
                logging.info("VM stopped")

                deactivate_license(vm_name, license_key)
            
        else:
            logging.info("Unsupported operation: ignoring")

    except Exception as e:
        logging.error(f"Unexpected error: {e}")


def load_secrets():
    try:
        return {
            "licenseKey": secret_client.get_secret("licenseKey").value,
            "apiKey": secret_client.get_secret("apiKey").value,
            "coreUser": secret_client.get_secret("coreUser").value,
            "corePwd": secret_client.get_secret("corePwd").value
        }
    except Exception as e:
        logging.error(f"Failed to load secrets: {e}")
        return None

def get_vm_ip(resource_group, vm_name):
    vm = compute_client.virtual_machines.get(resource_group, vm_name)
    nic_id = vm.network_profile.network_interfaces[0].id
    nic_name = nic_id.split("/")[-1]
    nic = network_client.network_interfaces.get(resource_group, nic_name)
    logging.info("nic: %s", nic)
    return nic.ip_configurations[0].private_ip_address

def get_vm_id(resource_group, vm_name):
    vm = compute_client.virtual_machines.get(resource_group, vm_name)
    logging.info("vm info: %s", vm)
    vm_id = vm.vm_id
    logging.info("vm_id: %s", vm_id)
    return vm_id

def get_session_id(ip, user, pwd):
    try:
        url = f"http://{ip}:8008/login"
        resp = requests.post(url, json={"user": user, "password": pwd}, timeout=5)
        logging.info("resp session id: %s", resp.json())
        return resp.json().get("session_id")
    except Exception as e:
        logging.error(f"Login failed: {e}")
        return None

def activate_license(ip, license_key, apikey, vm_name):
    try:
        url = f"http://{ip}:8008/admin/license/activation"
        headers = { "apikey": apikey }
        payload = {
            "activationKey": license_key,
            "quantity": 1,
            "comment": f"Activation for {vm_name}"
        }
        resp = requests.post(url, json=payload, headers=headers, timeout=5)
        logging.info("Activation response: %s", resp.json())
        return resp.json().get("success")
    except Exception as e:
        logging.error(f"Activation error: {e}")
        return None

def store_deployment_id(ip, apikey,vm_name):
    try:
        url = f"http://{ip}:8008/admin/license"
        headers = { "apikey": apikey }
        payload = {}
        resp = requests.get(url, json=payload, headers=headers, timeout=5)
        logging.info("License Information response: %s", resp.json())
        deployment_id = resp.json().get("deployment")
    
        returned_secret = secret_client.set_secret(vm_name.replace("_", "-"), deployment_id)
        print(f"Secret '{returned_secret.name}' set with version: {returned_secret.properties.version}")

    except Exception as e:
        logging.error(f"Store Deployment error: {e}")

def deactivate_license(vm_name, license_key):
    try:
        secret_name = vm_name.replace("_", "-")
        if check_secret_exists(secret_name):
            deployment_id = secret_client.get_secret(secret_name).value
            logging.info("License Deployment ID from Secret: %s", deployment_id)
            url = f"{ACTIVATION_SERVER_URL}/deactivation?key={license_key}&deployment={deployment_id}"
            logging.info("URL to deactivate: %s", url)
            resp = requests.get(url, timeout=5)
            if resp.status_code == 200:
                logging.info("Deactivation successful.")
                logging.debug("Response body: %s", resp.text)
                poller = secret_client.begin_delete_secret(secret_name)
                deleted = poller.result()  # waits until deletion completes
                print(f"Deleted secret: {deleted.name} at {deleted.deleted_date}")
                max_retries=90
                # Wait until the secret is fully in the deleted state
                if wait_until_deleted(secret_name,max_retries): 
                    logging.info("Secret purged successful.")
                else:
                    logging.error("Failed to purge secret after %d attempts.", max_retries)
                    raise Exception(f"Secret '{secret_name}' could not be purged after {max_retries} attempts.")

            else:
                logging.error("Deactivation failed with status %s: %s", resp.status_code, resp.text)
        else:
            logging.info(f"Deactivation Error, VM info was not stored to secret")
    except Exception as e:
        logging.error(f"Deactivation error: {e}")


def wait_until_deleted(secret_name, max_wait=60):
    for _ in range(max_wait):
        try:
            secret_client.get_deleted_secret(secret_name)
            print(f"Purged secret: {secret_name}")
            return True
        except Exception as e:
            time.sleep(1)
    return False


def check_secret_exists(secret_name):
    try:
        secret_client.get_secret(secret_name)
        return True
    except Exception as e:
        if "404" in str(e):
            return False
        raise