provider "aws" {
  profile = "ma"
  region  = "eu-west-2"
}

variable "env" {
  default = "dev"
  type    = string
}

variable "app_name" {
  default = "key-pairs"
  type    = string
}

locals {
  tags = {
    Application = var.app_name
    Environment = var.env
  }
}

resource "aws_key_pair" "key-1" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDD1jLVccCFJdtDMy8bgoldIF8NcqwQ7GpS05HIMsDSIKJtOFXKVfvzoEe3ASwEWN2IgJg6S1tuh8ns6PvxMdaUAlvfGdz9Kaca9nKYDXP1he610O60Qf45QpemzD1cFU/ThvXvPoSsX3iyLNTY7ul8eTUUbQ3INi+JOkudytv2J1SXh3umomFXtJ0kC0j4XZTjcUuKxHT6xUhyh5w7P/qM13y79tYQbRIBwtFr1cqgWQfSBct6nZzQukDIZ+MYv/IwiOCQh5j/21Dh2X5ADTkZFAeseJbdODL5MpBDcxYUHku4Avfrl9NDReqhNUubMlhhJ59frBBlRAEOk0IBs0lB"
  key_name   = "key pair"
  tags       = local.tags
}

resource "aws_key_pair" "key-2" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJtp9oipk32w7ErvhgyIFka4+Gtmy3it93XuvM7xTGIVUMdN7lm2xRmSOFd2GkmMC30VS97VhUxRnFloPSLXcWy1NJx+ZM65G6GFf7Hm9sj/Zj2AkB1D5gIBPQC4dfqKDAbbOUe7TnFEN0MTS8wCUjkIBNSGeunA15hI/Mdqf4kHEbx9555xPL2lJj+ABQNVmLYSEdTW6Wyt+j/XmA5YCDzonDKrVe7YrS38xEk4EgiI27p1EYO4+Cyug+PqoZXVeC0VZOEsetR92dksrr+8jqdPdyPgMkXkjScm1h2z/nes+mvLUqpRTO3WP6JOtRaiyYSr8VBAMMBcZG+69UcK74zZTkZ8YxoJcctWvMATqnZS2fl5tSi22ZEDDxwmOhz8t/zpEhJ2qxnWWnKNYDK/VWW2zCFMwlg3ekqoTxg9NcNUxSUv8NgYBHLq/viIE38HCze+1qy64t+X+jbBFg6DYRRIu8uU1t/enx9xG6Q4m6GCOqZLP5fANp4wwasdsV+X0="
  key_name   = "mx"
  tags       = local.tags
}
