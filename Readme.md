# AWS Automation & Validation

## What This Project Does

This project helps you:
1. Dynamically generate a Terraform configuration to deploy:
   - An EC2 instance
   - An Application Load Balancer (ALB)
2. Apply the Terraform to actually create the resources on AWS.
3. Validate that the EC2 and ALB exist and are running, using **boto3**.
4. Save the validation results in a neat JSON file.

---

## Where Everything Is

You'll find everything you need under:
workshop/terraform/hands_on_test/

yaml
Copy
Edit

---

## How to Run

### 1. Clone the Repo & Checkout the Right Branch
```bash
git clone <repository-url>
cd <repository-folder>
git checkout workshop/terraform
cd hands_on_test

aws_validation.json
It includes:
The EC2 instance ID
The instance state (should be running)
The public IP of the instance
The DNS name of the ALB

Example:

json
Copy
Edit
{
    "instance_id": "i-0123456789abcdef0",
    "instance_state": "running",
    "public_ip": "3.92.102.45",
    "load_balancer_dns": "my-alb-123456.elb.amazonaws.com"
}
Requirements
Python 3

Terraform installed

AWS credentials with permissions to create:

EC2 instances

Load Balancers

Security Groups

VPCs/Subnets (if needed)

You're all set 🚀.
