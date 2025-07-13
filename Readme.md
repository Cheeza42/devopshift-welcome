# AWS Infrastructure Deployment & Validation Automation

## Overview

This project automates the process of:
1. Dynamically generating a Terraform configuration file using **Jinja2**.
2. Deploying AWS infrastructure that includes:
   - An **EC2 instance**.
   - An **Application Load Balancer (ALB)**.
3. Validating the deployed resources with **boto3** to ensure:
   - The EC2 instance exists, is in a **running** state, and retrieve its **Public IP**.
   - The ALB exists and retrieve its **DNS Name**.
4. Storing the validation data in a structured JSON file.

---

## Project Structure

All relevant files for this exercise are located under:

workshop/terraform/hands_on_test/

yaml
Copy
Edit

### Key Components:
- `main.py` — Generates the Terraform template based on user input and runs Terraform init, plan, apply.
- `boto3_validation.py` — Validates the created AWS resources via boto3 and saves the data to a JSON file.
- `main.tf.j2` — Jinja2 Terraform template file.
- `aws_validation.json` — The output file containing validation results.

---

## Instructions to Run

### 1. Clone the Repository and Switch to the Correct Branch
```bash
git clone <repository-url>
cd <repository-folder>
git checkout workshop/terraform
cd hands_on_test
2. Configure AWS Credentials
Make sure your AWS CLI is configured with credentials that have sufficient permissions:

bash
Copy
Edit
aws configure
3. Install Required Python Packages
bash
Copy
Edit
pip install boto3 python-terraform Jinja2
4. Run Terraform Deployment
Execute the following command to:

Input infrastructure preferences (AMI, instance type, region, AZ, ALB name).

Render and save the Terraform configuration.

Deploy the infrastructure on AWS.

bash
Copy
Edit
python main.py
5. Validate AWS Resources
After successful deployment, run:

bash
Copy
Edit
python boto3_validation.py
This will:

Validate the EC2 instance's existence, state, and public IP.

Validate the ALB existence and DNS name.

Save the validation results into a JSON file named:

pgsql
Copy
Edit
aws_validation.json
Expected Output
Example of aws_validation.json:

json
Copy
Edit
{
    "instance_id": "i-0123456789abcdef0",
    "instance_state": "running",
    "public_ip": "3.92.102.45",
    "load_balancer_dns": "my-alb-123456.elb.amazonaws.com"
}
Additionally, logs of the validation process are available in the console and optionally in a log file (aws_validation.log if configured).

Prerequisites
Python 3.x

Terraform installed

AWS credentials with permissions to:

Create EC2 instances

Create Load Balancers

Manage VPC, Subnets, and Security Groups

Summary
At the end of this workflow you will have:

Deployed an EC2 instance and ALB on AWS dynamically.

Validated that both resources exist and are accessible.

Generated a JSON file summarizing the validation.

This project demonstrates Infrastructure as Code, automation of deployments, and post-deployment validation on AWS.
