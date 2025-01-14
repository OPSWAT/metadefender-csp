resource "azurerm_public_ip" "publicIp" {
  count               = var.PUBLIC_ENVIRONMENT ? 1 : 0
  name                = "${var.APP_NAME}-public-ip"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME
  allocation_method   = "Static"
  tags                = var.TAGS
}

data "template_file" "core_icap_user_data" {
  count = var.DEPLOY_CORE || var.DEPLOY_ICAP ? 1 : 0
  template = <<-EOT
    %{ if var.LICENSE_KEY != "" }
    LICENSE_KEY=${var.LICENSE_KEY}
    %{ endif }
    %{ if var.APIKEY != "" }
    APIKEY=${var.APIKEY}
    %{ endif }
  EOT
}

data "template_file" "mdss_user_data_script" {
  count = var.DEPLOY_MDSS && var.DEPLOY_MDSS_COSMOSDB ? 1 : 0
  template = <<-EOT
    #!/bin/bash
    %{ if var.DEPLOY_MDSS_COSMOSDB }
    echo 'MONGO_URL=${var.MDSS_COSMOSDB_ENDPOINT}' >> /etc/mdss/customer.env
    %{ endif }
    sudo docker rm -f $(docker ps -a -q)
    sudo mdss -c start
    touch /etc/mdss/finished_user_data
  EOT
}

### AUTOSCALING
resource "azurerm_lb" "vmss" {
  count               = var.AUTOSCALING ? 1 : 0
  name                = "${var.APP_NAME}-vmss-lb"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME

  frontend_ip_configuration {
    name                 = var.PUBLIC_ENVIRONMENT ? "PublicIPAddress" : "PrivateIPAddress"
    public_ip_address_id = var.PUBLIC_ENVIRONMENT ? azurerm_public_ip.publicIp[0].id : ""
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.TAGS
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  count               = var.AUTOSCALING ? 1 : 0
  loadbalancer_id     = azurerm_lb.vmss[0].id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss" {
  count               = var.AUTOSCALING ? 1 : 0
  loadbalancer_id     = azurerm_lb.vmss[0].id
  name                = "${var.APP_NAME}-running-probe"
  request_path        = var.DEPLOY_MDSS ? "/" : "/readyz"
  protocol            = "Http"
  port                = var.APP_PORT
}

resource "azurerm_lb_rule" "lbnatrule" {
  count                          = var.AUTOSCALING ? 1 : 0
  loadbalancer_id                = azurerm_lb.vmss[0].id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = var.APP_PORT
  backend_port                   = var.APP_PORT
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool[0].id]
  frontend_ip_configuration_name = var.PUBLIC_ENVIRONMENT ? "PublicIPAddress" : "PrivateIPAddress"
  probe_id                       = azurerm_lb_probe.vmss[0].id
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "Vmss" {
  count                       = var.AUTOSCALING ? 1 : 0
  name                        = "${var.APP_NAME}-vmscaleset"
  location                    = var.MD_REGION
  resource_group_name         = var.RG_NAME
  platform_fault_domain_count = 1
  sku_name                    = var.INSTANCE_TYPE
  instances                   = var.NUMBER_INSTANCES
  user_data_base64            = var.DEPLOY_CORE || var.DEPLOY_ICAP ? base64encode(data.template_file.core_icap_user_data[0].rendered) : var.DEPLOY_MDSS && var.DEPLOY_MDSS_COSMOSDB ? base64encode(data.template_file.mdss_user_data_script[0].rendered) : null

  os_profile {
    dynamic linux_configuration {
      for_each = strcontains(var.OFFER_PRODUCT, "windows") ? [] : [1]
      content {
        admin_username                    = "mdadmin"
        admin_password                    = var.VM_PWD
        disable_password_authentication   = false
      }
    }
    dynamic windows_configuration {
      for_each = strcontains(var.OFFER_PRODUCT, "windows") ? [1] : []
      content {
        admin_username                    = "mdadmin"
        admin_password                    = var.VM_PWD
      }
    }
  }

  plan {
    name      = var.SKU
    product   = var.OFFER_PRODUCT
    publisher = "opswatinc1619007967290"
  }

  source_image_reference {
    publisher = "opswatinc1619007967290"
    offer     = var.OFFER_PRODUCT
    sku       = var.SKU
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 150
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "${var.APP_NAME}-nic"
    primary = true
    network_security_group_id = var.NSG_ID

    ip_configuration {
      name                                   = "IPConfiguration"
      subnet_id                              = var.SUBNET_ID
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool[0].id]
      primary                                = true
    }
  }

  tags = var.TAGS

  lifecycle {
    ignore_changes = [
      tags,
      instances
    ]
  }
}

## SINGLE VM 

resource "azurerm_network_interface" "nic" {
  count               = var.AUTOSCALING ? 0 : 1
  name                = "${var.APP_NAME}-nic"
  location            = var.MD_REGION
  resource_group_name = var.RG_NAME

  ip_configuration {
    name                          = var.PUBLIC_ENVIRONMENT ? "PublicIPAddress" : "PrivateIPAddress"
    public_ip_address_id          = var.PUBLIC_ENVIRONMENT ? azurerm_public_ip.publicIp[0].id : ""
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.SUBNET_ID
  }

  tags = var.TAGS
}

resource "azurerm_linux_virtual_machine" "singlevm" {
  count                 = var.AUTOSCALING || strcontains(var.OFFER_PRODUCT, "windows") ? 0 : 1
  name                  = "${var.RG_NAME}-${var.APP_NAME}-vm"
  location              = var.MD_REGION
  resource_group_name   = var.RG_NAME
  network_interface_ids = [azurerm_network_interface.nic[0].id]
  size                  = var.INSTANCE_TYPE
  
  admin_username        = "mdadmin"
  admin_password        = var.VM_PWD
  disable_password_authentication = false
  user_data             = var.DEPLOY_CORE || var.DEPLOY_ICAP ? base64encode(data.template_file.core_icap_user_data[0].rendered) : var.DEPLOY_MDSS && var.DEPLOY_MDSS_COSMOSDB ? base64encode(data.template_file.mdss_user_data_script[0].rendered) : null

  plan {
    name      = var.SKU
    product   = var.OFFER_PRODUCT
    publisher = "opswatinc1619007967290"
  }


  source_image_reference {
    publisher = "opswatinc1619007967290"
    offer     = var.OFFER_PRODUCT
    sku       = var.SKU
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 150
    caching              = "ReadWrite"
  }

  tags = var.TAGS
}

resource "azurerm_windows_virtual_machine" "singlevm" {
  count                 = !var.AUTOSCALING && strcontains(var.OFFER_PRODUCT, "windows") ? 1 : 0
  name                  = "${var.RG_NAME}-${var.APP_NAME}-vm"
  location              = var.MD_REGION
  resource_group_name   = var.RG_NAME
  network_interface_ids = [azurerm_network_interface.nic[0].id]
  size                  = var.INSTANCE_TYPE
  
  admin_username        = "mdadmin"
  admin_password        = var.VM_PWD
  user_data             = var.DEPLOY_CORE || var.DEPLOY_ICAP ? base64encode(data.template_file.core_icap_user_data[0].rendered) : var.DEPLOY_MDSS && var.DEPLOY_MDSS_COSMOSDB ? base64encode(data.template_file.mdss_user_data_script[0].rendered) : null



  source_image_reference {
    publisher = "opswatinc1619007967290"
    offer     = var.OFFER_PRODUCT
    sku       = var.SKU
    version   = "latest"
  }

  plan {
    name      = var.OFFER_PRODUCT
    product   = var.SKU
    publisher = "opswatinc1619007967290"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 150
    caching              = "ReadWrite"
  }

  tags = var.TAGS
}