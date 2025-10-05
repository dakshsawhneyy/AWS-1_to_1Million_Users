# =============================================================================
# Security Groups CONFIGURATION
# =============================================================================
resource "aws_security_group" "web_sg" {
  name = "${var.project_name}-web_sg"
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}
resource "aws_security_group" "db_sg" {
  name = "${var.project_name}-db_sg"
  description = "Allows PostGres Traffic only from web server"
  vpc_id = module.vpc.vpc_id

  # Rule: Allow PostGres Traffic from our webserver security group
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    
    # Instead of CIDR Blocks, we do this
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = local.common_tags
}