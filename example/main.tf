module "vcn" {
    source = "./vcn"
    compartment_id = "${var.compartment_id}"
}

# Create a terraform.tfstate in an object storage bucket, create a pre-authenticated
# request and store it in the `address` property.
# terraform {
#     backend "http" {
#         update_method = "PUT"
#         address = "https://objectstorage.region.oraclecloud.com/access_uri
#     }
# }