variable "app_name" {
  type    = string
  default = "testapp-lb-asg-ec2"
}

variable "vpc_id" {
  type = string
}

variable "vpc_subnet_id" {
  type = string
}

variable "vpc_subnet_ids" {
  type = list(string)
}

variable "AZs" {
  type = list(string)
}

variable "ec2_image_id" {
  type = string
}

variable "ec2_user_data" {
  default = "pwd"
  type    = string
}

variable "ec2_instance_type" {
  default = "t2.micro"
  type    = string
}

variable "ebs_device_name" {
  default = "/dev/sda1"
  type    = string
}

variable "ebs_size" {
  default = 10
  type    = number
}

variable "ebs_encrypted" {
  default = false
  type    = bool
}

variable "port" {
  default = 80
  type    = number
}

variable "asg_min_size" {
  default = 0
  type    = number
}

variable "asg_max_size" {
  default = 4
  type    = number
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "spot_price" {
  default = "0.0025"
  type    = string
}

variable "ec2_metrics" {
  default = [
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]
  type = list(string)
}
