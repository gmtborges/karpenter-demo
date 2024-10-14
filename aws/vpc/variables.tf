variable "vpc_name" {
  type    = string
  default = "vpc-demo"

}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
