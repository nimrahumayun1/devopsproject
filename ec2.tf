

resource "aws_instance" "metabase" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type_metabase
  subnet_id                   = module.vpc.private_subnets[0]
  vpc_security_group_ids      = [aws_security_group.metabase_sg.id]
  key_name                    = var.ec2_key_name
  associate_public_ip_address = false

  tags = {
    Name = "metabasewithsql"
  }

  depends_on = [
    aws_db_instance.mysql
  ]

  user_data = base64encode(templatefile("${path.module}/userdata/metabase_ec2.sh", {
    mysql_DB_TYPE = var.mysql_DB_TYPE,
    mysql_DB_NAME = var.mysql_DB_NAME,
    mysql_DB_PORT = var.mysql_DB_PORT,
    mysql_DB_USER = var.mysql_username,
    mysql_DB_PASS = var.mysql_password,
    mysql_DB_HOST = aws_db_instance.mysql.address
  }))
}


# Find Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template for EC2
resource "aws_launch_template" "app_lt" {
  name_prefix            = "app-launch-template-"
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type_app
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(file("${path.module}/userdata/ec2_userdata.sh"))
}



# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                 = "app-asg"
  desired_capacity     = var.asg_desired_capacity
  max_size             = var.asg_max_size
  min_size             = var.asg_min_size

  vpc_zone_identifier  = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "ReactAppServer_Nimra"
    propagate_at_launch = true
  }
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type_bastion
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = var.ec2_key_name
  associate_public_ip_address = true

  tags = {
    Name = "bastion-host"
  }
}