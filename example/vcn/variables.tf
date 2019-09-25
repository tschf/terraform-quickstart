variable "compartment_id" {
    type ="string"
    description = "The compartment id where the network will live"
}

# VCN
variable "vcn_cidr_block" {
    type = "string"
    description = "CIDR block of the VCN"
    default = "10.0.0.0/16"
}

variable "vcn_display_name" {
    type = "string"
    description = "Display name for the VCN"
    default = "net1"
}

variable "vcn_dns_label" {
    type = "string"
    description = "DNS label for the VCN"
    default = "net1"
}

# Internet Gateway
variable "igw_display_name" {
    type = "string"
    description = "The display name for the internet gateway"
    default = "igw_net1"
}

# Route table
variable "igw_route_display_name" {
    type = "string"
    description = "The display name for the internet gateway route table"
    default = "route_net1"
}

variable "igw_route_destination" {
    type = "string"
    description = "The destination for the route"
    default = "0.0.0.0/0"
}
