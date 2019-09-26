output "vcn_name" {
    value = module.vcn.vcn_display_name
}

output "igw_name" {
    value = module.vcn.igw_display_name
    # To demonstrate sensitive at play, but not really sensitive
    sensitive = true
}