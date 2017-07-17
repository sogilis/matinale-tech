# some variables

variable "production_version" {
  type    = "string"
  default = "1"
}

variable "test_version" {
  type    = "string"
  default = "2"
}

variable "nb_production_task" {
  type    = "string"
  default = "6"
}

variable "nb_test_task" {
  type    = "string"
  default = "3"
}

variable "desired_capacity" {
  type    = "string"
  default = "3"
}