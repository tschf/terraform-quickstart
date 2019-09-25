Terrform comes from Hashicorp company. Allows a way for you to define your
infrastructure in "code" - a configuration, so to speak. Another benefit is that
if you ever wish to change providers, the change should be fairly
straightforward.

State file is how terraform knows what needs migrations. Into a file
terraform.tfstate (stored in root directory). It's a map of all the resources to
their resource identifier. 

Local state file - locally machine in JSON - common source of conflict from VCS.
Good for small teams (individual or small). Not good for scalability on larger
teams. With a team of any size, it's a good idea to place the file in object
storage. The state file can be configured to point at an external endpoint:

```
terraform {
    backend "http" {
        update_method = "PUT"
        address = "https://objectstorage.region.oraclecloud.com/access_uri
    }
}

This goes in the provider.tf file.
In object storage, create an empty file for the tfstate file
(terraform.tfstate). Then, in OCI create a pre-authenticate request URI (extend
the length so it lasts for a long time). Then use that URL in the config so
other users can update it with that URL.

Once that is configured 

For larger teams this

Provider

```
provider "oci" {
    version = ">= 3.0.0"
    tenancy_ocid = "${var.tenancy_ocid}"
    user_ocid = "${var.user_ocid}"
    fingerprint = "${var.fingerprint}"
    private_key_path = "${var.private_key_path}"
    region = "${var.region}"
}
```

As you can see these are using variables, these go in an `env_vars` file, that
looks like:

```
TODO
```

A user resource looks like:

user.tf:
```
resource "oci\_identity\_user" "tschf" {
    name = "tschf"
    description = "First terraform user"
}
```

terraform plan - shows what will be done
terraform apply - performs the actions you reviewed (outstanding tasks).
terraform show - shows info in the state file
terraform destroy - undoes changes pushed. iIt will backup the state file

For both plan and apply, you can use the target argument to only push a
particular resource.

```
terraform plan -target=oci\_identity\_user.tschf
```
-target can be an array, if you'd like multiple resources to be deployed
`-target resource1 -target resource2`.

Terraform initialised with `terraform init`


Modules

These are terraform configs inside of a folder

eg

```

module "vcn" {

    source "./vcn"
    compartment_ocid = "${var.todo_var}"
    tenancy_ocid = "${var.todo_var}"
    vcn_dns_name = "${var.todo_var}"
    label_prefix = "${var.todo_var}"
    vcn_name = "${var.todo_var}"
    vcn_cidr = "${var.todo_var}"
    subnet_cidr= "${var.todo_var}"
    availability_domains = "${var.todo_var}"
}
```

So, this would be in the root folder, then we would have a "vcn" folder

So the directory tree looks like:

env_vars
main.tf
provider.tf
variables.tf
vcn/

inside the vcn folder, there would be the file vcn.tf, that looks like:

```
resource "oci_core_vcn" "vcn" {
    cidr_block ="var_todo"
    compartment_id = "var_todo"
    display_name = "var_todo"
    dns_label = "var_todo"
}

resource "oci_core_internet_gateway" "ig" {
    compartment_id = "var_todo"
    display_name = "var_todo"
    vcn_id = "${oci_core_vcn.vcn.id"}
}

resource "oci_core_route_table" "ig_route" {

    compartment_id
    vcn_id
    display_name

    route_rules {
        destination
        network_entity_id = "${oci_core_internet_gateway.ig.id"}
    }

}
```

In the vcn folder, other files, to break up the config would be like:

datasources.tf
outputs.tf
security.tf
subnets.tf
variables.tf
vcn.tf


In the root directory, in your main.cf file, you would then define each module
used. So for example our vcn module:

```
module "vcn" {

    source = "./vcn"
    compartment_ocid
    tenancy_ocid
    vcn_dns_name
    label_prefix
    vcn_name
    vcn_cidr
    subnet_cidr
    availability_domains

}
```

Variables file typically defines variables like so:

```
variable "vcn_name" {
    type ="string"
    description = "name of the vcn"
    default = "tschf's network"
}
```
Modules need to be initialised. So you need to do terraform init. Putting the
data into variables means the developer won't need to go changing module source,
really.

Terraform has the concept of provisioners. These are execute scripts either
locally or remotely as part of the the apply or destruction process of creating
the infrastructure.

```
provisioner "local-exec" {
    command = "echo '${self.public_ip},'"
}

Provisioners work with chef, puppet, ansible, shell scripts. For remote exec the
provision is `remote-exec`. Runs inside the machine that was created. For this
example, this would go in your compute terraform file, along with inline
property instead of command, which is an array:

```
privisioner "remote-exec" {
    inline = [
        "touch /home/tschf/setup.sh",
    ]
}
```

The previsioner statement is a nested setting within another. e.g. instead of
compute instance, not at the same level.

An alternate approach is to use the null resource, and in the provisioner
specify a connect.

```
resource "null_resource" "remote-exec" {
    depends_on = ["oci_core_instance.TFInstance"]

   provisioner "remote-exec" {
        connection {
            agent = false
            timeout ="10m"
            host = "${data.oci_core_vnic.InstanceVnic.public_ip_address}"
            user = "ubuntu"
            private_key = "${var.ssh_private_key"
        }

        inline = [
            "touuch "/home/ubuntu/somefile"
        ]
    }
}
```


If using instance principal, you don't need to specify tenance_ocid, user_ocid,
fingerprint and private_key_path in the provider defn. But it needs to be
enabled in the provider by doing: auth = "instancePrincipal"
