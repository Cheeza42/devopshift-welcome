from jinja2 import Environment, FileSystemLoader
from python_terraform import Terraform

def choose_region():
    user_input = input("Enter AWS region: ").strip().lower()
    if user_input == "us-east-2":
        return user_input
    else:
        print("Invalid region. Defaulting to us-east-2.")
        return "us-east-2"

def choose_alb_name():
    while True:
        name = input("Enter a name for the Application Load Balancer (ALB): ").strip()
        if name:
            return name
        else:
            print("ALB name cannot be empty. Please try again.")

def choose_availability_zone():
    valid_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
    while True:
        zone = input("Choose Availability Zone (us-east-2a / us-east-2b / us-east-2c): ").strip().lower()
        if zone in valid_zones:
            return zone
        else:
            print("Invalid availability zone. Please choose from: us-east-2a, us-east-2b, us-east-2c.")

def render_template(user_choices):
    env = Environment(loader=FileSystemLoader('.'))
    template = env.get_template('template.j2')
    rendered = template.render(user_choices)

    with open('main.tf', 'w') as f:
        f.write(rendered)
    
    print("\nTerraform configuration has been rendered to main.tf")

def run_terraform():
    tf = Terraform(working_dir='.')

    print("Running terraform init...")
    return_code, stdout, stderr = tf.init()
    print(stdout)
    if return_code != 0:
        print("Terraform init failed:")
        print(stderr)
        return

    print("\nRunning terraform plan...")
    return_code, stdout, stderr = tf.plan()
    print(stdout)
    if return_code != 0:
        print("Terraform plan failed:")
        print(stderr)
        return

    print("\nRunning terraform apply...")
    return_code, stdout, stderr = tf.apply(skip_plan=True, capture_output=False)
    print(stdout)
    if return_code != 0:
        print("Terraform apply failed:")
        print(stderr)
        return

    print("\nTerraform apply completed successfully.\n")

    print("Fetching Terraform outputs...\n")
    return_code, outputs, stderr = tf.output()
    if return_code != 0:
        print("Failed to fetch outputs:")
        print(stderr)
        return

    for key, output in outputs.items():
        print(f"{key}: {output['value']}")

if __name__ == "__main__":
    ami = "ami-00ba4cffa98b2aa4b"
    instance_type = "t3.small"
    region = choose_region()
    availability_zone = choose_availability_zone()
    load_balancer_name = choose_alb_name()

    user_choices = {
        "ami": ami,
        "instance_type": instance_type,
        "region": region,
        "load_balancer_name": load_balancer_name,
        "availability_zone": availability_zone
    }

    print("\nSummary of your choices:")
    for key, value in user_choices.items():
        print(f"{key}: {value}")

    render_template(user_choices)
    

