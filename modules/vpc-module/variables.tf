variable "tag_name" {
  default = "main-vpc"
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "basename" {
  description = "Prefix used for all resources names"
  default     = "nbo"
}


variable "vpc_name" {
  type = string

}

variable "env_module" {
  type = any

}


