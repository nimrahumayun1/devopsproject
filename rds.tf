resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "mysql" {
  identifier             = var.mysql_db_identifier
  engine                 = "mysql"
 instance_class         = var.mysql_instance_class
  allocated_storage      = var.mysql_allocated_storage
  username               = var.mysql_username
  password               = var.mysql_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

resource "aws_db_instance" "postgres" {
  identifier             = var.postgres_db_identifier
  engine                 = "postgres"
  instance_class         = var.postgres_instance_class
  allocated_storage      = var.postgres_allocated_storage
  username               = var.postgres_username
  password               = var.postgres_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds_postgres_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}
