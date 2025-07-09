# Null Resource for Apache Installation
resource "null_resource" "provision_apache" {
  depends_on = [aws_instance.vm]

  # Trigger to force rerun whenever timestamp changes
  # This will force terraform to rerun the provisioner and update the welcome.html file if changed
  triggers = {
    always_run = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update",
      "sudo dnf install -y httpd",
      "echo '<h1>Welcome to the Web Server!</h1>' | sudo tee /var/www/html/welcome.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]

    connection {
      type     = "ssh"
      user     = var.admin_username
      password = var.admin_password
      host     = aws_instance.vm.public_ip
      timeout  = "1m"
    }
  }
}


# Updated Output for Server Information to use data source
output "server_info" {
  value       = "Please browse: http://${aws_instance.vm.public_ip}/welcome.html"
  description = "Instructions to access the server, note that port 80 is currently blocked."
}