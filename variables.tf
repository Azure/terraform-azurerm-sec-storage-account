#Required variables
variable "resource_group_name" {
  type        = string
  description = "The Resource Group in which to put the Storage Accounts."
}

#Optional variables
variable "storage_account_name" {
  type        = string
  description = "Storage Account name to create."
  default     = ""
}

variable "storage_account_tier" {
  type        = string
  description = "The Storage Account tier, either 'Standard' or 'Premium'."
  default     = "Standard"
}

variable "storage_account_replication_type" {
  type        = string
  description = "The type of replication to use for this Storage Account. Valid options are LRS, GRS, RAGRS and ZRS"
  default     = "LRS"
}

variable "allowed_ip_ranges" {
  type        = list(string)
  description = "List of IP Address CIDR ranges to allow access to Storage Account."
  default     = []
}

variable "permitted_virtual_network_subnet_ids" {
  type        = list(string)
  description = "List of the Subnet IDs to allow to access the Storage Account."
  default     = []
}

variable "bypass_internal_network_rules" {
  type        = bool
  description = "Bypass internal traffic to enable metrics and logging."
  default     = true
}

variable "enable_datalake_filesystem" {
  type        = bool
  description = "Install a datalake filesystem create."
  default     = false
}

variable "datalake_filesystem_name" {
  type        = string
  description = "The name of the datalake file system."
  default     = ""
}