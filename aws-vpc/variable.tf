variable "aws_zone" {
  default = "us-east-1a"
  description = "this is zonw where our resource will be allocated"

}

variable "common_tags" {
  default = "terraform_prince"
  description = "this is name of every resource that will be listed on aws"
}