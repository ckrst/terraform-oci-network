provider "oci" {
  tenancy_ocid = var.oracle_tenancy_ocid
  user_ocid    = var.oracle_user_ocid
  fingerprint  = var.oracle_fingerprint
  private_key  = var.oracle_private_key
  region       = var.oracle_region
}

resource "oci_core_vcn" "vcn" {
  compartment_id = var.oracle_compartment_id

  cidr_block   = "10.0.0.0/16"
  display_name = "${var.prefix}VCN"
  dns_label    = "${var.prefix}vcn"

  # cidr_blocks = [
  #   "10.0.0.0/16",
  # ]
  defined_tags = {
    "Oracle-Tags.CreatedBy" = "oracleidentitycloudservice/${var.oracle_account_email}"
    # "Oracle-Tags.CreatedOn" = "2021-04-09T05:17:53.824Z"
  }
  freeform_tags  = {}
  is_ipv6enabled = false
  timeouts {}

}

resource "oci_core_subnet" "subnet" {
  #Required
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.oracle_compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  #Optional
  display_name = "${var.prefix}Subnet"
  dns_label    = "${var.prefix}subnet"

  defined_tags = {
    "Oracle-Tags.CreatedBy" = "oracleidentitycloudservice/${var.oracle_account_email}"
    # "Oracle-Tags.CreatedOn" = "2021-04-09T05:17:56.745Z"
  }
  dhcp_options_id            = oci_core_dhcp_options.dhcp_options.id
  freeform_tags              = {}
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
  route_table_id             = oci_core_route_table.route_table.id
  # route_table_id = oci_core_vcn.vcn.default_route_table_id
  security_list_ids = [
    oci_core_security_list.security_list.id,
  ]
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.oracle_compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix}InternetGateway"
}

resource "oci_core_route_table" "route_table" {
  compartment_id = var.oracle_compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = "${var.prefix} Route Table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

locals {
  search_domain_name = "${oci_core_vcn.vcn.dns_label}.oraclevcn.com"
}

resource "oci_core_dhcp_options" "dhcp_options" {
  compartment_id = var.oracle_compartment_id
  vcn_id         = oci_core_vcn.vcn.id

  display_name = "${var.prefix} DHCP Options"

  options {
    custom_dns_servers  = []
    search_domain_names = []
    type                = "DomainNameServer"
    server_type         = "VcnLocalPlusInternet"
  }

  options {
    custom_dns_servers = []
    search_domain_names = [
      local.search_domain_name,
    ]
    type = "SearchDomain"
  }
}

resource "oci_core_security_list" "security_list" {
  compartment_id = var.oracle_compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix} Security List"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = false
  }
  # ingress_security_rules {
  #   protocol = "1" ICMP
  #   source = "10.0.0.0/16"
  #   source_type = "CIDR_BLOCK"
  #   stateless = false
  #   icmp_options {
  #     code = -1
  #     type = 3
  #   }
  # }
  # ingress_security_rules {
  #   protocol = "1" # ICMP
  #   source = "0.0.0.0/0"
  #   source_type = "CIDR_BLOCK"
  #   stateless = false
  #   icmp_options {
  #     code = 4
  #     type = 3
  #   }
  # }
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
    # icmp_options {
    #   # code = 4
    #   # type = 3
    # }
  }
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = false
    tcp_options {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group" "network_security_group" {
  compartment_id = var.oracle_compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix} Security Group"
}

resource "oci_core_network_security_group_security_rule" "network_security_group_security_rule_ssh" {
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  direction                 = "INGRESS"
  protocol                  = "6" #TCP
  description               = "Allow ssh port"
  source                    = var.my_ip
  source_type               = "CIDR_BLOCK"
  # stateless = false
  tcp_options {
    destination_port_range {
      min = "22"
      max = "22"
    }
  }
}
resource "oci_core_network_security_group_security_rule" "network_security_group_security_rule_dashboard" {
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  direction                 = "INGRESS"
  protocol                  = "6" #TCP
  description               = "Allow microk8s dashboard port"
  source                    = var.my_ip
  source_type               = "CIDR_BLOCK"
  # stateless = false
  tcp_options {
    destination_port_range {
      min = "10443"
      max = "10443"
    }
  }
}
resource "oci_core_network_security_group_security_rule" "network_security_group_security_rule_api" {
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  direction                 = "INGRESS"
  protocol                  = "6" #TCP
  description               = "Allow microk8s dashboard port"
  source                    = var.my_ip
  source_type               = "CIDR_BLOCK"
  # stateless = false
  tcp_options {
    destination_port_range {
      min = "16443"
      max = "16443"
    }
  }
}

resource "oci_core_network_security_group_security_rule" "network_security_group_security_rule_egress" {
  network_security_group_id = oci_core_network_security_group.network_security_group.id
  direction                 = "EGRESS"
  protocol                  = "all"
  description               = "Allow all tcp ports"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}