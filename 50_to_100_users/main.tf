# =============================================================================
# VPC CONFIGURATION
# =============================================================================

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}"
  cidr = "${var.vpc_cidr}"

  azs = local.azs
  public_subnets = local.public_subnets
  private_subnets = local.private_subnets

  # Enable NAT gateway
  enable_nat_gateway = true
  single_nat_gateway = var.single_nat_gateway

  # Internet Gateway
  create_igw = true

  # This tells the public subnets to automatically assign a public IP to any instance launched in them.
  map_public_ip_on_launch = true 
}

# =============================================================================
# Security Groups CONFIGURATION
# =============================================================================
resource "aws_security_group" "my_sg" {
  name = "${var.project_name}-my_sg"
  description = "Allows SSH and HTTP traffic"
  vpc_id = module.vpc.vpc_id

   # Rule 1: Allow SSH traffic from your IP address
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]    
  } 
  # Rule 2: Allow HTTP traffic from anywhere on the internet
  ingress {
    from_port   = 80
    to_port     =  80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This is the universal code for "anywhere"
  }
  # Rule 3: Allow HTTPS traffic from anywhere on the internet
  ingress {
    from_port   = 443
    to_port     =  443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # This is the universal code for "anywhere"
  }

  # New Rules for our services
  ingress {
    from_port   = 9000
    to_port     =  9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9001
    to_port     =  9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # -1 = all protocols
    cidr_blocks = ["0.0.0.0/0"] # anywhere
  }

  tags = local.common_tags
}

# =============================================================================
# EC2 CONFIGURATION
# =============================================================================
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-ec2"

  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "general-key-pair"
  subnet_id     = module.vpc.public_subnets[0]

  # Attach web security group to ssh into web_server
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  # Attaching user_data with EC2 -- my script acts as configuration management
  # Converting into tpl file, so we can pass env while calling the file
  user_data = templatefile("${path.module}/user-data.sh", {
    service_a_imageurl = "dakshsawhneyy/demo-service-a:latest"
    service_b_imageurl = "dakshsawhneyy/demo-service-b:latest"
  })

  tags = local.common_tags
}