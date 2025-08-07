
variable "role_name" {
  type = string
}

variable "description" {
  type = string
}

variable "actions" {
  type = list(string)
}

variable "assignable_scopes" {
  type        = map(string)
  description = "A map of all the locations that need to be added to the assignable scopes for the custom role."
}

variable "role_definition_location_resource_id" {
  type        = string
  description = "Resource ID of the Management Group or Subscription where the role definition will be created."
}