# Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = {
    Name    = "app-alb"
    Project = "devops-terraform-project"
  }
}

