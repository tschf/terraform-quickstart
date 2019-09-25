# Terraform Quickstart

## Overview

This document is to show basic usage and steps to get up and going with terraform. Since I'm currently working with Oracle Cloud, it has that focus. It my evolve over time to cover more ground.

## What is Terraform

Terrform comes from the company Hashicorp. It provides a way for you to define your
infrastructure in "code" - a configuration, so to speak. Another benefit is that
if you ever wish to change providers, the change should be fairly
straightforward.

## Install

Before you can do anything with Terraform, you need the application. I'm going to install it over the snap. Comparing the current published version to the version in the snap store, it's not the latest version - but seems pretty close, so should be sufficient.

```
sudo snap install terraform
# Verify it's in your path so you can start using it
type -a terraform
```

## Defining your infrastructure

In your file system, you will create `terraform` files, with the extension `tf`. The first step is to define a provider. So create a new file named `provider.tf`.

This file is defining where your infrastructure lives. Terraform supports many different [cloud providers](https://www.terraform.io/docs/providers/index.html), including but not limited to:

* AWS
* Azure
* GCP
* Oracle Cloud
* Many more

So, when defining your provider, you will want to first look here at your cloud platform. In here it provides you with not only the provider syntax, but also all the resources that you can define.

So, for Oracle Cloud, the example given is:

```
provider "oci" {
    tenancy_ocid = "${var.tenancy_ocid}"
    user_ocid = "${var.user_ocid}"
    fingerprint = "${var.fingerprint}"
    private_key_path = "${var.private_key_path}"
    region = "${var.region}"
}
```

You will notice most of these setting values are variables. So, first off, we better understand how variables are defined.

### Variables

Variables are deinfed in a `tf` file. So, in the root folder of your terraform config, named `variables.tf`. And then variables would be defined like so:

```terraform
variable "region" {
    type ="string"
    description = "The accounts region"
    default = "ap-sydney-1"
}
```

For these more secure details, you will want an environment file to set these values, and Terraform will pick these up as values:

```
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..xxx
export TF_VAR_compartment_ocid=ocid1.compartment.oc1..xxx
export TF_VAR_user_ocid=ocid1.user.oc1..xxx
export TF_VAR_fingerprint=
export TF_VAR_private_key_path=$HOME/.oci/oci_api_key_personal.pem
```

What to set these values at? These are just values used by and API/SDK, so if you install the oci-cli tool, you would have configured this and have a file: `$HOME/.oci/config`, so I suggest to extract the values from here.

Once these first two basic parts are set up, you will now want to run terraform init. This will download the plugin for your given provider. The provider is a binary file that is downloaded into the `.terrform` folder so it knows how to interact with the provider each time you deploy changes.

```
terraform init

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "oci" (3.44.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.oci: version = "~> 3.44"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

After the initialisation of terraform, we can begin by defining our infrastructure set up.

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
