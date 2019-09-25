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

## Provider configuration

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
    # Running on OCI Infra? Can use dynamic groups and the InstancePrincipal auth setting
    # auth = "InstancePrincipal"
}
```

If you are running your terraform through an OCI instance, you can avoid setting up authorisation against your account and use the `InstancePrincipal` auth setting.

You will notice most of these setting values are variables. So, first off, we better understand how variables are defined.

### Variables

Variables are deinfed in a `tf` file. So, in the root folder of your terraform config, named `variables.tf`. And then variables would be defined like so:

```
variable "region" {
    type ="string"
    description = "The accounts region"
    default = "ap-sydney-1"
}
```

For these more secure details, you will want an environment file to set these values, and Terraform will pick these up as values:

```bash
export TF_VAR_tenancy_ocid=ocid1.tenancy.oc1..xxx
export TF_VAR_compartment_id=ocid1.compartment.oc1..xxx
export TF_VAR_user_ocid=ocid1.user.oc1..xxx
export TF_VAR_fingerprint=xx:yy
export TF_VAR_private_key_path=$HOME/.oci/oci_api_key.pem
```

Then before you run your `terraform` command, source these variables. I've named my file auth_env, so I would run

```bash
source auth_env
```

You can extract these values from your console in OCI, excluding the fingerprint and private key path. For these, the best way would be to install the oci-cli command and run:

```bash
oci setup config
```

With this initial basic set up, we can get started with out configuration. The first step is the `init` operation. This will download the plugin for your provider defined in `provider.tf`. This downloads a binary file into the `.terrform` folder in your root project directory so it knows how to interact with the provider each time you deploy changes.

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

First of all, let's define our users that will be managed with our terraform config. In your root folder, create a new file `user.tf`. Over on the Terraform docs, under the subsection `Identity Resources` we can find the specs for a user. It falls under `oci_identity_user`. At minimum, you will want to set `description` and `name`. This gives as a resource that looks like:

```
resource "oci_identity_user" "tschf" {
    name = "tschf"
    description = "First terraform user"
}
```

Now that we have a basic resource, we are ready to see terraform in action. Before deploying any changes you will likely want to see the actions terraform is going to apply. This is done with the command `terraform plan`.

```
$ terraform-plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # oci_identity_user.tschf will be created
  + resource "oci_identity_user" "tschf" {
      + capabilities         = (known after apply)
      + compartment_id       = (known after apply)
      + defined_tags         = (known after apply)
      + description          = "First terraform user"
      + email                = (known after apply)
      + external_identifier  = (known after apply)
      + freeform_tags        = (known after apply)
      + id                   = (known after apply)
      + identity_provider_id = (known after apply)
      + inactive_state       = (known after apply)
      + name                 = "tschf"
      + state                = (known after apply)
      + time_created         = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

If everything looks good, you apply the changes with `terraform apply`.

### Modules

To keep your terraform structure more maintainable, you will want to leverage terraforms [module](https://www.terraform.io/docs/modules/index.html) system. This is basically breaking up your config into a folder structure. For example, we may have a folder for the core network, another for compute instances. So in your root directory, you have a `main.tf` file. The source property will tell us in which folder the module is defined in.

```
module "vcn" {
    source "./vcn"
    compartment_id = "${var.compartment_id}"
}
```

In the vcn folder, we need a new `variables.tf` file - there may be some variables re-declared that were in your root folder (they aren't inherited). Then, we would expect to have a new file, `vcn.tf` with our network properties ([docs](https://www.terraform.io/docs/providers/oci/r/core_vcn.html)):

```
resource "oci_core_vcn" "test_vcn" {
    cidr_block = "${var.vcn_cidr_block}"
    compartment_id = "${var.compartment_id}"
    display_name = "${var.vcn_display_name}"
    dns_label = "${var.vcn_dns_label}"
}

resource "oci_core_internet_gateway" "igw" {
    compartment_id = "${var.compartment_id}"
    display_name = "${var.igw_display_name}"
    vcn_id = "${oci_core_vcn.vcn.id"}
}

resource "oci_core_route_table" "igw_route" {

    compartment_id = "${var.compartment_id}
    vcn_id
    display_name = "${var.igw_route_display_name}"

    route_rules {
        destination
        network_entity_id = "${oci_core_internet_gateway.ig.id"}
    }

}
```

(as you can see here, you can reference previously defined resource properties)

Whenever you add a new module, you need to re-initialise to make that module "available" to use. So we can verify this configuration with:

```
terraform init
terraform plan
```

### Deploying

As has been previously discussed through this document, to push the changes out to your infrastructure, you would typically run the two commands:

```
terraform plan
terraform apply
```

The `plan` operation is a good practice to review what changes you will be pushing. If you have a lot of changes and want to deploy individual changes, you can restrict what get's deployed with the `-target` argument, where you specify the resource you want to deploy. In the example so far, we have set up a user and our VCN. So, suppose I only want to deploy the the VCN module, I could do:

```
terraform plan -target=module.vcn
```

(I can deploy multiple targets if there is large set of changes with `target=target1 -target=target2)

### State file

State file is how terraform knows what needs migrations. Into a file terraform.tfstate (stored in root directory). It's a map of all the resources to their resource identifier. The state can either be stored locally or remotely, where local is the default. If leaving as the default, it will be put into the file `terraform.tfstate` in the root directory. The format of this file is in JSON, but it's a good idea not to directly consume this file but rather use the `terraform show` command.

A best practice is to NOT use a local tfstate file, but rather store it remotely - especially when you are working on a team. Otherwise the file we get to be out of date, and start causing conflicts. The state file is how Terraform knows what to deploy. 

A good idea therefore is to place this file into OCI's object storage (or other remote location), and then in your `provider.tf` file, define this like so:

```
terraform {
    backend "http" {
        update_method = "PUT"
        address = "https://objectstorage.region.oraclecloud.com/access_uri
    }
}
```

### Key commands


terraform plan - shows what will be done
terraform apply - performs the actions you reviewed (outstanding tasks).
terraform show - shows info in the state file
terraform destroy - undoes changes pushed. iIt will backup the state file

For both plan and apply, you can use the target argument to only push a
particular resource.

### Provisioners

Terraform has the concept of provisioners. These are execute scripts either locally or remotely as part of the the apply or destruction process of creating the infrastructure.

```
provisioner "local-exec" {
    command = "echo '${self.public_ip},'"
}
```

Provisioners work with chef, puppet, ansible, shell scripts. For remote exec the provision is `remote-exec`. Runs inside the machine that was created. For this example, this would go in your compute terraform file, along with inline
property instead of command, which is an array:

```
provisioner "remote-exec" {
    inline = [
        "touch /home/tschf/setup.sh",
    ]
}
```

The previsioner statement is a nested setting within another resource. If a system has already been deployed, an alternate approach is to use the null resource, and in the provisioner specify a connect.

```
resource "null_resource" "remote-exec" {
    depends_on = ["oci_core_instance.TFInstance"]

   provisioner "remote-exec" {
        connection {
            agent = false
            timeout ="10m"
            host = "${data.oci_core_vnic.InstanceVnic.public_ip_address}"
            user = "ubuntu"
            private_key = "${var.ssh_private_key}"
        }

        inline = [
            "touch "/home/ubuntu/somefile"
        ]
    }
}
```


If using instance principal, you don't need to specify tenance_ocid, user_ocid,
fingerprint and private_key_path in the provider defn. But it needs to be
enabled in the provider by doing: auth = "instancePrincipal"

### Rollback changes

You can undo your infrastructure with the command `terraform destroy`.

## License

<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.  
Copyright 2019, Trent Schafer