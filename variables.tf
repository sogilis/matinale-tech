# some variables

variable "production_version" {
  type    = "string"
  default = "1"
}

variable "test_version" {
  type    = "string"
  default = "1"
}

variable "nb_production_task" {
  type    = "string"
  default = "6"
}

variable "nb_test_task" {
  type    = "string"
  default = "0"
}

variable "desired_capacity" {
  type    = "string"
  default = "0"
}