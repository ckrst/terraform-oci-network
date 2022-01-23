variable "prefix" {
  default     = "mynetwork"
  description = "Prefix for the network resources"
}

variable "oracle_compartment_id" {
  description = "The OCID of the compartment to create the network in"
}

variable "oracle_account_email" {
  description = "The email of the Oracle Cloud account"
}

variable "oracle_tenancy_ocid" {
  description = "The OCID of the tenancy to create the network in"
}

variable "oracle_user_ocid" {
  description = "The OCID of the user to create the network in"
}

variable "oracle_fingerprint" {
  description = "The fingerprint of the user to create the network in"
}
variable "oracle_private_key" {
  description = "The private key of the user to create the network in"
}
variable "oracle_region" {
  description = "The region to create the network in"
}



variable "my_ip" {
  description = "The IP address allowed for ssh"
  default     = "0.0.0.0/0"
}