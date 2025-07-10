output "VMSS_ID" {
  value = var.AUTOSCALING ? azurerm_orchestrated_virtual_machine_scale_set.Vmss[0].id : ""
}