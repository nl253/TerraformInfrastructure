provider "aws" {
  region  = "eu-west-2"
  profile = "ma"
}

variable "db_name" {
  default = "mydatabase"
  type    = string
}

variable "db_engine" {
  default = "aurora-postgresql"
  type    = string
}

variable "cluster_name" {
  default = "my-database-cluster"
  type    = string
}

variable "db_username" {
  default = "mx"
  type    = string
}

variable "db_password" {
  default = "regix123"
  type    = string
}

resource "aws_db_instance" "db" {
  allocated_storage   = 20
  skip_final_snapshot = true
  storage_type        = "gp2"
  engine              = "postgres"
  instance_class      = "db.t2.micro"
  name                = "mydb"
  username            = "mx"
  password            = "regix123"
}
