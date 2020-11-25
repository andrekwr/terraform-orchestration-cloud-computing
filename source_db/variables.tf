variable "region" {
}

variable "instance_type" {
  default = "t2.micro"
}

variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}

variable "ami" {
  description = "AMI image ubuntu"
  default = {
   "us-east-1" = "ami-06eb9a138c82951a5"#"ami-0817d428a6fb68645"
   "us-east-2" = "ami-0e82959d4ed12de3f"
    } // Amazon Linux
}

# variable "ami-us-east-2" {
#   description = "AMI image ubuntu us-east2"
#   default = "ami-0e82959d4ed12de3f" // Amazon Linux
# }