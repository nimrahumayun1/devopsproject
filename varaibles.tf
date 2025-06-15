variable "mysql_DB_TYPE" {
  description = "MySQL database type for Metabase"
  type        = string
}

variable "mysql_DB_NAME" {
  description = "MySQL database name for Metabase"
  type        = string
}

variable "mysql_DB_PORT" {
  description = "MySQL database port for Metabase"
  type        = number
}

# Subnet Group
variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

# MySQL DB
variable "mysql_db_identifier" {
  description = "Identifier for the MySQL RDS instance"
  type        = string
}
variable "mysql_instance_class" {
  description = "Instance class for MySQL RDS"
  type        = string
}
variable "mysql_allocated_storage" {
  description = "Allocated storage for MySQL RDS"
  type        = number
}
variable "mysql_username" {
  description = "Username for MySQL RDS"
  type        = string
}
variable "mysql_password" {
  description = "Password for MySQL RDS"
  type        = string
  sensitive   = true
}

# Postgres DB
variable "postgres_db_identifier" {
  description = "Identifier for the PostgreSQL RDS instance"
  type        = string
}
variable "postgres_instance_class" {
  description = "Instance class for PostgreSQL RDS"
  type        = string
}
variable "postgres_allocated_storage" {
  description = "Allocated storage for PostgreSQL RDS"
  type        = number
}
variable "postgres_username" {
  description = "Username for PostgreSQL RDS"
  type        = string
}
variable "postgres_password" {
  description = "Password for PostgreSQL RDS"
  type        = string
  sensitive   = true
}


# ========== EC2 + ASG Variables ==========

variable "ec2_key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_type_metabase" {
  description = "Instance type for Metabase EC2"
  type        = string
}

variable "instance_type_app" {
  description = "Instance type for App EC2 in launch template"
  type        = string
}

variable "instance_type_bastion" {
  description = "Instance type for Bastion EC2"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of EC2 instances in ASG"
  type        = number
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
}
