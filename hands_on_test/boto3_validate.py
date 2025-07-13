import boto3
import json
import logging
from python_terraform import Terraform

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

class AWSValidator:
    def __init__(self, region='us-east-2', working_dir='.'):
        self.region = region
        self.working_dir = working_dir
        self.ec2_client = boto3.client('ec2', region_name=self.region)
        self.elb_client = boto3.client('elbv2', region_name=self.region)
        self.tf = Terraform(working_dir=self.working_dir)

    def get_terraform_outputs(self):
        try:
            logging.info("Fetching Terraform outputs...")
            return_code, stdout, stderr = self.tf.cmd('output', '-json')
            if return_code != 0:
                raise Exception(f"Terraform output failed: {stderr}")
            outputs = json.loads(stdout)
            logging.info("Terraform outputs fetched successfully.")
            return outputs
        except Exception as e:
            logging.error(f"Error fetching Terraform outputs: {e}")
            raise

    def validate_resources(self, instance_id, alb_dns_name):
        try:
            logging.info(f"Validating EC2 instance: {instance_id}")
            ec2_response = self.ec2_client.describe_instances(InstanceIds=[instance_id])
            reservations = ec2_response.get('Reservations', [])
            if not reservations:
                raise Exception("EC2 instance not found.")

            instance = reservations[0]['Instances'][0]
            instance_state = instance['State']['Name']
            public_ip = instance.get('PublicIpAddress')
            logging.info(f"Instance state: {instance_state}, Public IP: {public_ip}")

            if instance_state != 'running':
                raise Exception(f"EC2 instance is not running. Current state: {instance_state}")

            logging.info(f"Validating ALB DNS name: {alb_dns_name}")
            lb_response = self.elb_client.describe_load_balancers()
            load_balancer_dns = None
            for lb in lb_response['LoadBalancers']:
                if lb['DNSName'] == alb_dns_name:
                    load_balancer_dns = lb['DNSName']
                    break

            if not load_balancer_dns:
                raise Exception("ALB not found.")

            validation_data = {
                "instance_id": instance_id,
                "instance_state": instance_state,
                "public_ip": public_ip,
                "load_balancer_dns": load_balancer_dns
            }

            with open('aws_validation.json', 'w') as f:
                json.dump(validation_data, f, indent=4)

            logging.info("Validation data saved to aws_validation.json")
            return validation_data

        except Exception as e:
            logging.error(f"Error during validation: {e}")
            raise

    def run(self):
        logging.info("Starting AWS resources validation...")
        outputs = self.get_terraform_outputs()
        instance_id = outputs['instance_id']['value']
        alb_dns_name = outputs['lb_dns_name']['value']
        validation_data = self.validate_resources(instance_id, alb_dns_name)
        logging.info("AWS resources validation completed successfully.")
        return validation_data

if __name__ == "__main__":
    validator = AWSValidator()
    validator.run()



