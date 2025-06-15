mysql_DB_TYPE = "mysql"
mysql_DB_NAME = "metabase"
mysql_DB_PORT = 3306


# Subnet Group
db_subnet_group_name = "main-subnet-group"

# MySQL DB
mysql_db_identifier        = "mysql-db"
mysql_instance_class       = "db.t3.micro"
mysql_allocated_storage    = 20
mysql_username             = "admin"
mysql_password             = "Nimra123"

# PostgreSQL DB
postgres_db_identifier     = "postgres-db"
postgres_instance_class    = "db.t3.micro"
postgres_allocated_storage = 20
postgres_username          = "postgresadmin"
postgres_password          = "Nimra123"

# EC2 Key Pair
ec2_key_name = "project"

# Instance Types
instance_type_metabase = "t2.micro"
instance_type_app      = "t3.micro"
instance_type_bastion  = "t2.micro"

# Auto Scaling Group Configuration
asg_desired_capacity = 2
asg_min_size         = 2
asg_max_size         = 2

