output "vm_public_ip" {
  value = azurerm_public_ip.pip-ALONALBA.ip_address
  depends_on = [ null_resource.check_public_id ]
  description = "Public IP address of the VM"
}
