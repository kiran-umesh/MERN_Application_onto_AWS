# MERN_Application_onto_AWS
Evidence: https://github.com/kiran-umesh/MERN_Application_onto_AWS.git 
Deploying a MERN Application on AWS
Part 1: Infrastructure Setup with Terraform
1.	AWS Setup and Terraform Initialization:
o	Configure AWS CLI and authenticate with your AWS account.
o	Initialize a new Terraform project targeting AWS. 
    Done using the Terraform script as shown in the GITHUB repository
2.	VPC and Network Configuration:
o	Create an AWS VPC with two subnets: one public and one private. 
    Done pk1-vpc created with 2 subnets 1 provate and 1 public
 ![image](https://github.com/user-attachments/assets/cf5ace57-2338-4bdb-991c-45cb10836eba)

•	Set up an Internet Gateway and a NAT Gateway.
 ![image](https://github.com/user-attachments/assets/96e946f3-efe8-4747-8592-55de0b0a69e4)

•	Configure route tables for both subnets.
 ![image](https://github.com/user-attachments/assets/0897c1f0-b84a-498d-8f5c-93e89be1a172)

3.	EC2 Instance Provisioning:
o	Launch two EC2 instances: one in the public subnet (for the web server) and another in the private subnet (for the database).
o	Ensure both instances are accessible via SSH (public instance only accessible from your IP). All the 3 isntance are launches as shown below
 ![image](https://github.com/user-attachments/assets/c1abf2bf-d8a0-4bab-b1ba-7166a2561234)

4.	Security Groups and IAM Roles:
o	Create necessary security groups for web and database servers.
o	created in the terraform script itself
o	Set up IAM roles for EC2 instances with required permissions.
5.	Resource Output:
o	Output the public IP of the web server EC2 instance.
Part 2: Configuration and Deployment with Ansible
1.	Ansible Configuration:
o	Configure Ansible to communicate with the AWS EC2 instances.
    Created ansible host file and able to ping to the ec2 instances
 ![image](https://github.com/user-attachments/assets/9cface3a-0153-43a2-8b93-2e50bd3e4090)

2.	Web Server Setup:
o	Write an Ansible playbook to install Node.js and NPM on the web server.
o	Clone the MERN application repository and install dependencies. 
    Created web.yaml and ran it using ansible. It is is able to update the REACT server with all the dependencies.
3.	Database Server Setup:
o	Install and configure MongoDB on the database server using Ansible.
o	Secure the MongoDB instance and create necessary users and databases. Created app.yaml and ran it using ansible. It is is able to update the REACT server with all the dependencies.
4.	Application Deployment:
o	Configure environment variables and start the Node.js application.
o	Ensure the React frontend communicates with the Express backend.
    Application deployment is complete and able to see the following image.	
 ![image](https://github.com/user-attachments/assets/327a444b-c58a-414d-93b1-bc6d38e56a20)

![image](https://github.com/user-attachments/assets/5a9a477d-3dd4-4170-bc64-3db2d09699b2)

 
5.	Security Hardening:
o	Harden the security by configuring firewalls and security groups.
o	Implement additional security measures as needed (e.g., SSH key pairs, disabling root login).

