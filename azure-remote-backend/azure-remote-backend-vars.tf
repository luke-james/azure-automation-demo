# Company
variable "company" {
  type        = string
  description = "This variable defines the name of the company"
  default = "vmcompany"
}
# Environment
variable "environment" {
  type        = string
  description = "This variable defines the environment to be built"
  default = "development"
}
# Azure Region
variable "location" {
  type        = string
  description = "Azure region where the resource group will be created"
  default     = "West Europe"
}