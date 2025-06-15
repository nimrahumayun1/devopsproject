# Target Group for Docker App (port 8080)
resource "aws_lb_target_group" "app_tg" {
  name        = "app-tg"
  port        = 8080                    # Must match EXPOSE in Docker and your app!
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"              # Targets EC2 instances

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  tags = {
    Name    = "app-tg"
    Project = "devops-terraform-project"
  }
}

# HTTP Listener for ALB (port 80 → target group on port 8080)
resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}