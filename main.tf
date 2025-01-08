provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "pk1_vpc" {
  cidr_block = "10.1.0.0/24"
  tags = {
    Name = "pk1-vpc"
  }
}

resource "aws_subnet" "pk1_public_subnet" {
  vpc_id                  = aws_vpc.pk1_vpc.id
  cidr_block              = "10.1.0.0/25"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = {
    Name = "pk1-public-subnet"
  }
}

resource "aws_subnet" "pk1_private_subnet" {
  vpc_id            = aws_vpc.pk1_vpc.id
  cidr_block        = "10.1.0.128/25"
  availability_zone = "us-west-2a"
  tags = {
    Name = "pk1-private-subnet"
  }
}

resource "aws_internet_gateway" "pk1_igw" {
  vpc_id = aws_vpc.pk1_vpc.id
  tags = {
    Name = "pk1-igw"
  }
}

resource "aws_route_table" "pk1_public_rt" {
  vpc_id = aws_vpc.pk1_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pk1_igw.id
  }

  tags = {
    Name = "pk1-public-rt"
  }
}

resource "aws_route_table" "pk1_private_rt" {
  vpc_id = aws_vpc.pk1_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pk1_nat.id
  }

  tags = {
    Name = "pk1-private-rt"
  }
}

resource "aws_route_table_association" "pk1_public_assoc" {
  subnet_id      = aws_subnet.pk1_public_subnet.id
  route_table_id = aws_route_table.pk1_public_rt.id
}

resource "aws_route_table_association" "pk1_private_assoc" {
  subnet_id      = aws_subnet.pk1_private_subnet.id
  route_table_id = aws_route_table.pk1_private_rt.id
}

resource "aws_eip" "pk1_nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "pk1_nat" {
  allocation_id = aws_eip.pk1_nat_eip.id
  subnet_id     = aws_subnet.pk1_public_subnet.id
  tags = {
    Name = "pk1-nat-gateway"
  }
  depends_on = [aws_eip.pk1_nat_eip]
}

resource "aws_security_group" "pk1_webserver_sg" {
  vpc_id = aws_vpc.pk1_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000  
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pk1-webserver-sg"
  }
}

resource "aws_security_group" "pk1_nodejs_sg" {
  vpc_id = aws_vpc.pk1_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/24"]
  }
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["10.1.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pk1-nodejs-sg"
  }
}

resource "aws_instance" "pk1_webserver_ec2" {
  ami                    = "ami-05d38da78ce859165"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.pk1_public_subnet.id
  key_name               = "studentpk-key"
  vpc_security_group_ids = [aws_security_group.pk1_webserver_sg.id]

  tags = {
    Name = "pk1-webserver-ec2"
  }
}

resource "aws_instance" "pk1_nodejs_ec2" {
  ami                    = "ami-05d38da78ce859165"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.pk1_private_subnet.id
  key_name               = "rampk-key"
  vpc_security_group_ids = [aws_security_group.pk1_nodejs_sg.id]

  tags = {
    Name = "pk1-nodejs-ec2"
  }
}

resource "aws_instance" "ansible_control_node" {
  ami                    = "ami-05d38da78ce859165" # Replace with the desired Ubuntu AMI
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.pk1_public_subnet.id
  key_name               = "studentpk-key"
  vpc_security_group_ids = [aws_security_group.pk1_webserver_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    # Update and upgrade the system
    sudo apt update -y && sudo apt upgrade -y

    # Install necessary packages
    sudo apt install -y curl unzip tar git apache2 openjdk-21-jdk python3 python3-pip docker.io ufw

    # Configure UFW (Uncomplicated Firewall)
    sudo ufw allow OpenSSH
    sudo ufw allow 80/tcp
    sudo ufw allow 8080/tcp
    sudo ufw --force enable

    # Install Boto3 (AWS SDK for Python)
    pip3 install boto3

    # Update package list and install Ansible
    sudo apt update
    sudo apt install -y ansible

    # Verify Ansible installation
    ansible --version

    # Ensure pip3 is installed
    sudo apt install -y python3-pip
  EOF

  tags = {
    Name = "ansible-control-node"
  }
}
