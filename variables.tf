variable "source_dir" {}
variable "build_cmd" {}
variable "name" {}
variable "handler" {}
variable "runtime" {}
variable "layers" {
  default = []
}
variable "variables" {
  default = { }
}

variable "timeout" {
  default = 3
}

variable "memory_size" {
  default = 128
}
variable "tags" {
  default = {}
}
variable "force" {
  default = false
}