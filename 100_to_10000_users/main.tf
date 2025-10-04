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


# =============================================================================
# EC2 with Auto-Scaling Group and Elastic Load Balancer CONFIGURATION
# =============================================================================
resource "aws_launch_template" "my_launch_template" {
  name_prefix = "aws-100to10000-"     # generate a unique name everytime
  image_id = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = "general-key-pair" 
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    service_a_imageurl = "dakshsawhneyy/demo-service-a:latest"
    service_b_imageurl = "dakshsawhneyy/demo-service-b:latest"
    db_host    = module.db.db_instance_address
    db_user    = "dakshsawhneyy"
    db_pass    = "mySuperSecretPassword123"
    db_name    = "awsscalabilitytest"
  }))

  tags = local.common_tags
}

### Load Balancer
resource "aws_lb" "my_lb" {
  name = "${var.project_name}-lb"
  internal = false    # LB is internet-facing
  load_balancer_type = "application"
  security_groups = [aws_security_group.web_sg.id]
  subnets = module.vpc.public_subnets

  tags = local.common_tags
}
# Where to send the load
resource "aws_lb_target_group" "my_tg" {
  name = "${var.project_name}-tg"
  port = 9000   # Routes load to 9000 port -- Service A
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id

  health_check {
    path = "/healthy"     # /healthy route is created in service A
  }

  tags = local.common_tags
}
# When and how to send the load
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port = "80"
  protocol = "HTTP"

  # Specifies what to do with the request
  default_action {
    type = "forward"    # forwards the request
    target_group_arn = aws_lb_target_group.my_tg.arn   # forwards to the target groups
  }
}

### Create auto-scaling group that creates and manages the instance
resource "aws_autoscaling_group" "my_asg" {
  name = "100to10000asg"
  min_size = 2
  max_size = 4
  desired_capacity    = 2
  vpc_zone_identifier = module.vpc.public_subnets

  launch_template {
    id = aws_launch_template.my_launch_template.id
    version = "$Latest"
  }

  # This links the ASG to the Load Balancer's Target Group -- required for instances health checks
  target_group_arns = [aws_lb_target_group.my_tg.arn]

  # This helps the ASG replace unhealthy instances
  health_check_type = "ELB"   # Let load balancer check instance health
  health_check_grace_period = 300
}

# =============================================================================
# RDS CONFIGURATION
# =============================================================================
module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "awsscalabilitytest"

  engine            = "postgres"
  engine_version    = "15.7"
  major_engine_version = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  db_name  = "awsscalabilitytest"
  username = "dakshsawhneyy"
  password = "dakshsuperstar"
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = local.common_tags

  # AWS will automatically create a standby replica of your database in a different Availability Zone
  multi_az = true

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  # DB parameter group
  family = "postgres15"
}