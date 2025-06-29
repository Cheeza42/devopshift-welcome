output "vm_public_ip" {
  value = azurerm_public_ip.pip-ALONALBA.ip_address
  description = "Public IP address of the VM"
}
