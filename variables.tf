variable "prefix" {
    default = "mynetwork"
    description = "Prefix for the network resources"
}

variable "oracle_compartment_id" {
    description = "The OCID of the compartment to create the network in"
}

variable "oracle_account_email" {
    description = "The email of the Oracle Cloud account"
}

variable "my_ip" {
    description = "The IP address allowed for ssh"
    default = "0.0.0.0/0"
}