variable "instance_type" {
  type        = string                     # The type of the variable, in this case a string
  default     = "t2.micro"                 # Default value for the variable
  description = "The type of EC2 instance" # Description of what this variable represents
}

variable "ubuntu_image" {
  type        = string
  default     = "ami-0ecb62995f68bb549"
  description = "Ubuntu Image AMI ID"
}

variable "your_ip_address"  {
  type        = string
  description = "Your home's IP address"
}