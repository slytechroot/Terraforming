
"""manage.py: Script to deploy SEC699 resources"""

__author__      = "Wouter Bloeyaert (@someniak)"
__copyright__   = "SANS, NVISO"

import argparse
import os
import subprocess
import sys
import json
import glob
import boto3
import time

# Variables
ACTIONS = ['deploy', 'destroy', 'destroy_target', 'list', 'configure']
REGIONS = ["eu-west-1", "us-east-1", "ap-southeast-2", "ap-northeast-1"]
CURRENT_WORKING_DIRECTORY = os.getcwd()
PROD_WORKING_DIRECTORY = os.path.join(CURRENT_WORKING_DIRECTORY, "prod")
OWNER = "SANS"

# Helper functionality 
def validate_version_tag(value):
    if len(value) > 20 or len(value) < 1:
        raise argparse.ArgumentTypeError("version tag needs to have a length between 1 and 20")
    return value

def create_key():
    ssh_key_file = get_ssh_key_file(region,version)
    if  not os.path.isfile(ssh_key_file) or not os.path.isfile(ssh_key_file + ".pub"):
        print("Key file not found!")
        print("Generating SSH key")
        print("ssh-keygen -b 2048 -t rsa -f %s -q -N" % ssh_key_file)
        os.system("ssh-keygen -b 2048 -t rsa -f %s -q -N '' " % ssh_key_file)
        os.system("chmod 0600 %s" % ssh_key_file)


def remove_lab_files(region, version):
    terraform_file = get_terraform_state_file(region, version)
    ssh_key_file = get_ssh_key_file(region,version)
    ovpn_file = get_ovpn_file(region, version)
    
    os.remove(ssh_key_file)
    os.remove(ssh_key_file+ ".pub")
    os.remove(ovpn_file)
    os.remove(terraform_file)
    os.remove(terraform_file + ".backup")

def get_terraform_state_file(region, version):
    filename = "terraform_%s_%s.tfstate" % (region, version)
    return os.path.join(CURRENT_WORKING_DIRECTORY, filename)

def get_ssh_key_file(region, version):
    filename = "ssh_key_%s_%s" % (region, version)
    return os.path.join(PROD_WORKING_DIRECTORY, filename)

def get_ovpn_file(region, version):
    filename = "student_%s_%s.ovpn" % (region, version)
    return os.path.join(CURRENT_WORKING_DIRECTORY, filename)

def run_command(command, cwd):
    try:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, cwd=cwd)
        while True:
            output = process.stdout.readline()
            if output == b'':
                break
            if output:
                output = str(output.strip(), 'utf-8')
                print(output)
        process.communicate()
        if process.returncode != 0:
            print("Error encountered with command, please investigate or contact your instructor...")
            sys.exit(process.returncode)
        return process.returncode
    except subprocess.CalledProcessError:
        sys.exit("Error encountered with command, please investigate or contact your instructor...")

def get_terraform_output(region, version):
    command = ["terraform", "output"]
    command.append("-state")
    command.append(get_terraform_state_file(region, version))
    command.append("-json")
    output = subprocess.check_output(command, cwd=PROD_WORKING_DIRECTORY)
    output = output.decode('utf8').replace("'", '"')
    output = json.loads(output)
    return output

# Core functionality


def deploy(region, version):
    print("\033[1mDeploying the lab environment on version %s in AWS region %s\033[0m" % (version, region))
    create_key()

    command = ["terraform", "apply"]
    command.append("-state")
    command.append(get_terraform_state_file(region, version))
    command.append("-var")
    command.append("version_tag=%s"% version)
    command.append("-var")
    command.append("aws_region=%s"% region)
    command.append("-var")
    command.append("owner=%s"% OWNER)
    command.append("-auto-approve")
    run_command(["terraform", "init"], PROD_WORKING_DIRECTORY)
    run_command(command, PROD_WORKING_DIRECTORY)

    output = get_terraform_output(region, version)
    commando_vm_ip = output["commando_vm_ip"]["value"]
    ovpn_file = "student_%s_%s.ovpn" %(region, version)
    print("""
   _____ ______ _____  __ ___   ___  
  / ____|  ____/ ____|/ // _ \ / _ \ 
 | (___ | |__ | |    / /| (_) | (_) |
  \___ \|  __|| |   | '_ \__, |\__, |
  ____) | |___| |___| (_) |/ /   / / 
 |_____/|______\_____\___//_/   /_/  
                                     
    \033[1mThe lab environment is ready for use in region %s on version %s\033[0m

    CommandoVPN can be reached on \033[1m%s\033[0m via RDP.
    The OpenVPN configuration files can be found in the script folder.
    You can connect using \033[1msudo openvpn %s\033[0m
    """ % (region, version, commando_vm_ip, ovpn_file))

def destroy(region, version):
    terraform_file = get_terraform_state_file(region, version)
    if not os.path.isfile(terraform_file):
        print("No active deployment for version %s in AWS region %s" % (version, region))
        return
    else:
        print("Destroying the lab environment on version %s in AWS region %s" % (version, region))

    command = ["terraform", "destroy"]
    command.append("-state")
    command.append(terraform_file)
    command.append("-var")
    command.append("version_tag=%s"% version)
    command.append("-var")
    command.append("aws_region=%s"% region)
    command.append("-var")
    command.append("owner=%s"% OWNER)
    command.append("-auto-approve")

    run_command(["terraform", "init"], PROD_WORKING_DIRECTORY)
    run_command(command, PROD_WORKING_DIRECTORY)
    remove_lab_files(region, version)

    print("""
   _____ ______ _____  __ ___   ___  
  / ____|  ____/ ____|/ // _ \ / _ \ 
 | (___ | |__ | |    / /| (_) | (_) |
  \___ \|  __|| |   | '_ \__, |\__, |
  ____) | |___| |___| (_) |/ /   / / 
 |_____/|______\_____\___//_/   /_/  
                                     
    \033[1mThe lab environment has been destroyed in region %s on version %s\033[0m
    """%(region, version))
def destroy_target(region, version):
    terraform_file = get_terraform_state_file(region, version)
    if not os.path.isfile(terraform_file):
        print("No active deployment for version %s in AWS region %s" % (version, region))
        return
    else:
        print("Destroying the DC lab environment on version %s in AWS region %s" % (version, region))

    command = ["terraform", "destroy"]
    command += ["-state", get_terraform_state_file(region, version)]
    command += ["-target", "module.sec699.aws_instance.dc"]
    command += ["-target", "module.sec699.aws_instance.dc2"]
    command += ["-target", "module.sec699.aws_instance.win19"]
    command += ["-target", "module.sec699.aws_instance.sql"]
    command += ["-target", "module.sec699.aws_instance.win10"]
    command += ["-var", "version_tag=%s"% version]
    command += ["-var", "aws_region=%s"% region]
    command += ["-var", "owner=%s"% OWNER]
    command.append("-auto-approve")


    run_command(["terraform", "init"], PROD_WORKING_DIRECTORY)
    run_command(command, PROD_WORKING_DIRECTORY)

    output = get_terraform_output(region, version)
    commando_vm_ip = output["commando_vm_ip"]["value"]
    ovpn_file = "student_%s_%s.ovpn" %(region, version)

    print("""
   _____ ______ _____  __ ___   ___  
  / ____|  ____/ ____|/ // _ \ / _ \ 
 | (___ | |__ | |    / /| (_) | (_) |
  \___ \|  __|| |   | '_ \__, |\__, |
  ____) | |___| |___| (_) |/ /   / / 
 |_____/|______\_____\___//_/   /_/  
                                     
    \033[1mThe DC lab environment has been destroyed in region %s on version %s\033[0m
    The CommandoVM, SOC and C2 machines can still be reached using RDP or OpenVPN.

    CommandoVPN can be reached on \033[1m%s\033[0m via RDP.
    The OpenVPN configuration files can be found in the script folder.
    You can connect using \033[1msudo openvpn %s\033[0m
    """%(region, version, commando_vm_ip, ovpn_file))

def list_active_deployments():
    print("""
   _____ ______ _____  __ ___   ___  
  / ____|  ____/ ____|/ // _ \ / _ \ 
 | (___ | |__ | |    / /| (_) | (_) |
  \___ \|  __|| |   | '_ \__, |\__, |
  ____) | |___| |___| (_) |/ /   / / 
 |_____/|______\_____\___//_/   /_/  
                                    
    """)
    print("\033[1mCurrently active resources:\033[0m")
    for file in glob.glob("*.tfstate"):
        with open(file) as json_file:
            data = json.load(json_file)
            splitted = file.split("_")
            region = splitted[1]
            version = splitted[2].strip(".tfstate")
            rdp = data["outputs"]["commando_vm_ip"]["value"]
            print('\033[1m+ Version %s on region %s (RDP: %s)\033[0m'% (version, region, rdp))
            for resource in data["resources"]:
                if resource["type"] == "aws_instance":
                    private_ip = resource["instances"][0]["attributes"]["private_ip"]
                    print("   - %s - %s" %(resource["name"], private_ip))

def pause(region, version):
    terraform_file = get_terraform_state_file(region, version)
    if not os.path.isfile(terraform_file):
        print("No active deployment for version %s in AWS region %s" % (version, region))
        return

    aws_instances = []

    with open(terraform_file) as json_file:
        data = json.load(json_file)
        rdp = data["outputs"]["commando_vm_ip"]["value"]
        print('\033[1mPausing all resources for version %s in region %s (RDP: %s)\033[0m'% (version, region, rdp))
        for resource in data["resources"]:
            if resource["type"] == "aws_instance":
                private_ip = resource["instances"][0]["attributes"]["private_ip"]
                id = resource["instances"][0]["attributes"]["id"]
                aws_instances.append(id)
                print("   - %s - %s - %s" %(resource["name"], private_ip, id))
    
    ec2 = boto3.resource('ec2', region_name=region)
    ec2.instances.filter(InstanceIds = aws_instances).stop()

    instances = ec2.instances.filter(InstanceIds = aws_instances)
    while not all(i.state['Name'] == "stopped" for i in instances):
        time.sleep(1)
        print('   ...Obtaining latest status...')
        instances = ec2.instances.filter(InstanceIds = aws_instances)

    print('\033[1mAll resources for version %s in region %s have been paused!\033[0m'% (version, region))

def start(region, version):
    terraform_file = get_terraform_state_file(region, version)
    if not os.path.isfile(terraform_file):
        print("No active deployment for version %s in AWS region %s" % (version, region))
        return
        
    aws_instances = []

    with open(terraform_file) as json_file:
        data = json.load(json_file)
        rdp = data["outputs"]["commando_vm_ip"]["value"]
        print('\033[1mStarting all resources for version %s in region %s (RDP: %s)\033[0m'% (version, region, rdp))
        for resource in data["resources"]:
            if resource["type"] == "aws_instance":
                private_ip = resource["instances"][0]["attributes"]["private_ip"]
                id = resource["instances"][0]["attributes"]["id"]
                aws_instances.append(id)
                print("   - %s - %s - %s" %(resource["name"], private_ip, id))
    
    ec2 = boto3.resource('ec2', region_name=region)
    ec2.instances.filter(InstanceIds = aws_instances).start()

    instances = ec2.instances.filter(InstanceIds = aws_instances)
    while not all(i.state['Name'] == "running" for i in instances):
        time.sleep(1)
        print('Obtaining latest status...')
        instances = ec2.instances.filter(InstanceIds = aws_instances)

    print('\033[1mAll resources for version %s in region %s are running!\033[0m'% (version, region))  

def aws_configure():
    os.system("aws configure")

# Script entrypoint
if __name__ == "__main__":

    description = "This script launches a SEC699 student lab environment in AWS. It requires AWS CLI and terraform to be installed and properly configured."
    epilog = ""

    parser = argparse.ArgumentParser(description=description, epilog=epilog)
    subparsers = parser.add_subparsers(help='Action to execute', dest="command")

    parser_deploy = subparsers.add_parser('deploy', help='Deploy a SANS SEC699 lab environment')
    parser_deploy.add_argument('-t', '--tag', dest='version_tag', type=validate_version_tag, required=True, help='Version tag of lab environment')
    parser_deploy.add_argument('-r', '--region', dest="region", choices=REGIONS, required=True, help='AWS regions to work with')

    parser_destroy = subparsers.add_parser('destroy', help='Destroy a deployed SANS SEC699 lab environment')
    parser_destroy.add_argument('-t', '--tag', dest='version_tag', type=validate_version_tag, required=True, help='Version tag of lab environment')
    parser_destroy.add_argument('-r', '--region', dest="region", choices=REGIONS, required=True, help='AWS regions to work with')

    parser_destroy_target = subparsers.add_parser('destroy_target', help='Destroy the DC lab target instances deployed in a SANS SEC699 lab environment')
    parser_destroy_target.add_argument('-t', '--tag', dest='version_tag', type=validate_version_tag, required=True, help='Version tag of lab environment')
    parser_destroy_target.add_argument('-r', '--region', dest="region", choices=REGIONS, required=True, help='AWS regions to work with')

    parser_pause = subparsers.add_parser('pause', help='Pause all lab instances deployed in a SANS SEC699 lab environment')
    parser_pause.add_argument('-t', '--tag', dest='version_tag', type=validate_version_tag, required=True, help='Version tag of lab environment')
    parser_pause.add_argument('-r', '--region', dest="region", choices=REGIONS, required=True, help='AWS regions to work with')

    parser_start = subparsers.add_parser('start', help='Start all lab instances deployed in a SANS SEC699 lab environment')
    parser_start.add_argument('-t', '--tag', dest='version_tag', type=validate_version_tag, required=True, help='Version tag of lab environment')
    parser_start.add_argument('-r', '--region', dest="region", choices=REGIONS, required=True, help='AWS regions to work with')

    parser_list = subparsers.add_parser('list', help='List all currently active SANS SEC699 deployments')

    parser_list = subparsers.add_parser('configure', help='Configure access credentials for AWS.')

    args = parser.parse_args()
    action = args.command

    # Execute the requested action
    if action is None:
        parser.print_help()
        exit(0)
    if action == "list":
        list_active_deployments()
        exit(0)
    if action == "configure":
        aws_configure()
        exit(0)
    
    version = args.version_tag
    region = args.region
    locals()[action](region, version)
