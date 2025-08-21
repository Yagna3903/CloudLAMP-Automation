variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "lamp-aws-key"
}

variable "ssh_ingress_cidr" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
