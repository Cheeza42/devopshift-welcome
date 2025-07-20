resource "null_resource" "provision_apache" {
  depends_on = [null_resource.validate_ip]

  # Trigger to force rerun whenever timestamp changes
  # This will force terraform to rerun the provisioner and update the welcome.html file if changed
  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y httpd",
      "sudo systemctl enable --now httpd",  
      "echo '<h1>Welcome to the Web Server!</h1>' | sudo tee /var/www/html/welcome.html"
    ]

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = aws_instance.vm.public_ip
      timeout  = "2m"
    }
  }
}


# Updated Output for Server Information to use data source
output "server_info" {
  value       = "Please browse: http://${aws_instance.vm.public_ip}/welcome.html"
  description = "Instructions to access the server, note that port 80 is currently blocked."
}

output "vm_public_ip" {
  value = aws_instance.vm.public_ip
}