provider "aws" {
 region = var.region
}

variable "region" {
 default = "us-west-1"
}

variable "subnet" {
 default = "subnet-06acd0b316280afeb" 
}
variable "ami" {
 default = "ami-061ad72bc140532fd"
 }
variable "vm_name" {
 default = "vm-alonalba"
}

variable "admin_username" {
 default = "admin-user"
}

variable "admin_password" {
 default = "Password123!"
}

variable "vm_size" {
 default = "t2.micro"
}