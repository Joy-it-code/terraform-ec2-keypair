# Define AWS Provider
provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

# Generate Key Pair
resource "aws_key_pair" "example_keypair" {
  key_name   = "example-keypair"
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key
}

# Create a Security Group to Allow HTTP (Port 80) Traffic
resource "aws_security_group" "web_sg" {
  name        = "allow_http"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 Instance
resource "aws_instance" "example_instance" {
  ami           = "ami-08b5b3a93ed654d19"  # Replace with your preferred AMI ID
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example_keypair.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello World from $(hostname -f)</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "Terraform-Web-Server"
  }
}

# Output Public IP
output "public_ip" {
  value = aws_instance.example_instance.public_ip
}
