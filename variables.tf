# Var file for AWS deployment
variable "access_key" {}

variable "secret_key" {}

variable "region" {}

variable "ubuntu_ami" {}

variable "public_subnet" {
type    = "list"
}

variable "private_subnet" {
type    = "list"
}
variable "count" {}

variable "pr_key_path" {}

variable "pb_key_path" {}

variable "inst_key" {}