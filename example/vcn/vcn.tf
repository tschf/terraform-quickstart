resource "oci_core_vcn" "test_vcn" {
    cidr_block = "${var.vcn_cidr_block}"
    compartment_id = "${var.compartment_id}"
    display_name = "${var.vcn_display_name}"
    dns_label = "${var.vcn_dns_label}"
}

resource "oci_core_internet_gateway" "igw" {
    compartment_id = "${var.compartment_id}"
    display_name = "${var.igw_display_name}"
    vcn_id = "${oci_core_vcn.test_vcn.id}"
}

resource "oci_core_route_table" "igw_route" {

    compartment_id = "${var.compartment_id}"
    vcn_id = "${oci_core_vcn.test_vcn.id}"
    display_name = "${var.igw_route_display_name}"

    route_rules {
        network_entity_id = "${oci_core_internet_gateway.igw.id}"
        destination = "${var.igw_route_destination}"
    }

}