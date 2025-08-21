data "aws_ami" "ubuntu_2204" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "lamp_sg" {
  name        = "lamp-sg"
  description = "Allow SSH, HTTP, HTTPS"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress_cidr
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 433
    to_port     = 433
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
    Project = "CloudLAMP-Automation"
  }
}

resource "aws_instance" "lamp" {
  ami                         = data.aws_ami.ubuntu_2204.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.lamp_sg.id]
  associate_public_ip_address = true

  tags = {
    Name    = "lamp-ec2"
    Project = "CloudLAMP-Automation"
  }
}

resource "aws_eip" "lamp_eip" {
  instance = aws_instance.lamp.id
  domain   = "vpc"

  tags = {
    Name    = "lamp-eip"
    Project = "CloudLAMP-Automation"
  }
}

output "ec2_public_ip" {
  value = aws_eip.lamp_eip.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.lamp.id
}
