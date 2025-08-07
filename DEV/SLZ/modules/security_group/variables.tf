###    Resources

variable "name" {
  type = string
}

variable "description" {
  type = string
}

variable "owner_upn" {
  type = string
}

variable "member_upns" {
  type = map(string)
}