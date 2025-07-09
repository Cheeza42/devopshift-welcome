resource "aws_instance" "vm" {
  ami           = "ami-061ad72bc140532fd" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  subnet_id              =   "subnet-06acd0b316280afeb"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
  Name = var.vm_name
  }
  user_data = <<-EOF
   #!/bin/bash
     useradd -m -s /bin/bash ${var.admin_username}
        echo "${var.admin_username}:${var.admin_password}" | chpasswd
        usermod -aG wheel ${var.admin_username}
        echo "${var.admin_username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${var.admin_username}
        chmod 440 /etc/sudoers.d/${var.admin_username}
        sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sudo systemctl restart sshd  
EOF
}

output "vm_public_ip" {
 value = aws_instance.vm.public_ip
}