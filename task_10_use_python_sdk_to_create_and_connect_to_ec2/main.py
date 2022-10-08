import ast
import json
import os
import shlex
import subprocess
from typing import Dict

import boto3
import paramiko
from paramiko.client import SSHClient


def main():
    with EC2InstanceSource('ec2-key', 'ami-08c40ec9ead489470', 'subnet-097d612b9299e7400') as ec2_instance:
        ip_v4 = ec2_instance.get_instance_info()['ipv4']
        client = SSHClient()
        client.load_host_keys(os.path.expanduser('~/.ssh/known_hosts'))
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(ip_v4, username='ubuntu', key_filename='ec2-key.pem')
        
        _, stdout, _ = client.exec_command('export TERM=xterm')
        _, stdout1, _ = client.exec_command('curl ifconfig.me')
        _, stdout2, _ = client.exec_command('cat /etc/os-release')
        _, stdout3, _ = client.exec_command('top -n 1')
        _, stdout4, _ = client.exec_command('df -H')

        print("Public ipv4 is: ", stdout1.read())
        print("-" * 100)
        print("OS info: ", stdout2.read())
        print("-" * 100)
        print("CPU usage: ", stdout3.read())
        print("-" * 100)
        print("Disk info: ", stdout4.read())

        subprocess.run(
            shlex.split(
                f'''rsync -Pav -e
                "ssh -i ec2-key.pem"
                install_aws_cli.sh ubuntu@{ip_v4}:/home/ubuntu/'''
            )
        )
        _, stdout5, _ = client.exec_command('chmod 700 install_aws_cli.sh && source install_aws_cli.sh')

        _, stdout6, _ = client.exec_command("/usr/local/bin/aws --version")
        print("-" * 100)
        print("Is aws installed?")
        print(stdout6.read())


class EC2InstanceSource:
    def __init__(self, key_pair_filename_without_extension: str, image_id: str, subnet_id: str):
        self.key_pair_filename_without_extension = key_pair_filename_without_extension
        self.image_id = image_id
        self.subnet_id = subnet_id

    def get_instance_info(self) -> Dict[str, str]:
        return self.ec2_instance_obj.get_instance_info()

    def __enter__(self, ):
        self.ec2_instance_obj = _EC2Instance(
            self.key_pair_filename_without_extension,
            self.image_id,
            self.subnet_id
        )
        return self.ec2_instance_obj

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.ec2_instance_obj.destroy()


class _EC2Instance:
    def __init__(self, key_pair_filename_without_extension: str, image_id: str, subnet_id: str):
        self.ec2 = boto3.client('ec2')
        self.key_pair_filename_without_extension = key_pair_filename_without_extension

        self._create_key_pair()
        self.instance: Dict[str, str] = self._create_instance(image_id, subnet_id)

    def get_instance_info(self) -> Dict[str, str]:
        return self.instance

    def _create_key_pair(self):
        if os.path.exists(f'{self.key_pair_filename_without_extension}.pem'):
            return

        with open(f'{self.key_pair_filename_without_extension}.pem', 'w') as f:
            key_pair = self.ec2.create_key_pair(KeyName=self.key_pair_filename_without_extension)
            f.write(str(key_pair['KeyMaterial']))
            os.system(f'chmod 400 {self.key_pair_filename_without_extension}.pem')

    def _create_instance(self, image_id, subnet_id) -> Dict[str, str]:
        temp = subprocess.Popen(
            shlex.split(f"""aws ec2 run-instances
                        --image-id {image_id}
                        --count 1
                        --instance-type t2.micro
                        --key-name {self.key_pair_filename_without_extension}
                        --subnet-id {subnet_id}
                        --associate-public-ip-address"""), stdout=subprocess.PIPE)

        answer_from_aws = str(temp.communicate())
        instance_id = self._parse_aws_response(answer_from_aws)

        temp = subprocess.Popen(
            shlex.split(f"""
                aws ec2 describe-instances 
                --instance-ids {instance_id}
                --query 'Reservations[*].Instances[*].PublicIpAddress' 
                --output text
            """), stdout=subprocess.PIPE
        )
        answer_from_aws = str(temp.communicate())
        public_ipv4 = (ast.literal_eval(answer_from_aws)[0].decode('utf-8')).split('\n')[0]

        return {'ipv4': public_ipv4, 'instance_id': instance_id}

    def destroy(self):
        import pdb; pdb.set_trace()
        instance_id = self.instance["instance_id"]
        subprocess.call(
            shlex.split(
                f"""
                aws ec2 terminate-instances --instance-ids {instance_id}
                """
            )
        )

    def _parse_aws_response(self, aws_response: str):
        response_data_in_dict = json.loads(ast.literal_eval(aws_response)[0].decode('utf-8'))
        return response_data_in_dict['Instances'][0]['InstanceId']


if __name__ == '__main__':
    main()
