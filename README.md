# Terraform-EC2-SG-ELB

## Creates EC2, 2 Security Groups and Load Balancers

```
PS: it is hard coded version, needs to add your own  
    - region
    - ami
    - instance_type 
    - availability_zone
    - vpc_id  (used default vpc)

    - instances id  ( add manually after created instances )

```

```
provider "aws" {
  profile = "MyAWS"
  region  = "us-east-2"
}

resource "aws_instance" "my_ec2" {
  count                  = 2
  instance_type          = "t2.micro"
  ami                    = "ami-00dfe2c7ce89a450b"
  availability_zone      = "us-east-2a" 
  user_data              = file("user_data.sh")
  vpc_security_group_ids = [aws_security_group.elb.id]

  tags = {
    Name = "terraform-ec2"
  }

}
resource "aws_security_group" "allow_tls" {
  name = "ec2-security-group"
  ingress = [
    {
      description      = "TLS"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true
    },
    {
      description      = "TLS"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true
    }

  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false
      description      = "TLS"
    }
  ]
}

resource "aws_security_group" "elb" {
  name        = "terraform_elb_sg"
  description = "Terraform ELB SG"
  vpc_id      = "vpc-034f8ce0c3e575f3a"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "my_elb" {
  name               = "my-terraform-elb"
  security_groups    = [aws_security_group.elb.id]
  availability_zones = data.aws_availability_zones.all.names

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }


  health_check {
    target              = "TCP:80"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  // ELB attachments
  instances                   = ["i-0af92944243240a4a", "i-0c27dc6c31916e789"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

}


```