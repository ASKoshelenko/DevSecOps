variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "project_name" {
  description = "Name of the project, used in resource names"
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, prod)"
  type        = string
}


variable "data_location" {
  description = "The location where the Email Communication service stores its data at rest. Possible values are Africa, Asia Pacific, Australia, Brazil, Canada, Europe, France, Germany, India, Japan, Korea, Norway, Switzerland, UAE, UK and United States. Changing this forces a new Email Communication Service to be created."
  type        = string
}

# variable "communication_service_tags" {
#   description = "A mapping of tags which should be assigned to the Communication Service."
#   type = map(string)
#   default = {
#     "project_name" = "marathon"
#   }
# }

# variable "email_communication_service_tags" {
#   description = "A mapping of tags which should be assigned to the Email Communication Service."
#   type = map(string)
#   default = {
#     "project_name" = "marathon"
#   }
# }

# variable "communication_service_email_domain_tags" {
#   description = "A mapping of tags which should be assigned to the Email Communication Service Domain."
#   type = map(string)
#   default = {
#     "project_name" = "marathon"
#   }
# }
