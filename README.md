# Microblog Deployment

This repository provides some scripts around the deployment of a microblog.

## Prerequisites

* AWS CLI with configured credentials
* Terraform
* Ansible

## Deployment

### Overview

The deployment consists of multiple scripts resp. tools, wrapped in an hierarchy of `Makefile`s in order to deploy everything at once, or individually, with just one simple command.

```bash
Makefile # Wrapper
|- terraform # Infrastructure
   |- Makefile
|- microblog # Application
   |- Makefile
|- ansible # Deployment
   |- Makefile
```

The get everything set up at once, simply run

```bash
make
```

Caution: This will run infrastructure creation as well as deployment commands. Existing infrastructure previously created with this script might be changed. There's no safety check. Prerequisistes as outlined in the above sections still apply.

### Basic infrastructure

To create the necessary infrastructe on AWS, provide your AWS credentials as per [Terraform's documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and run the following command.

```bash
make infra
```

This will also generate some files necessary to run the Ansible playbook within this repository.

### Build

In order to deploy the application to the virtual machine provisioned, it has to be built before :)

```bash
make build
```

### Deploy

`Make`'s deployment target will copy the files generated by Terraform to the Ansible playbook's folder and execute the playbook against the virtual machine provisioned before.

```bash
make deploy
```

## Next steps

After successful deployment, the microblog application as well as monitoring UI can be accessed via the browser. The public DNS names can be retrieved with the following commands:

```bash
# Following commands will return the EC2's public DNS name, e.g. ec2-some-ip.eu-central-1.compute.amazonaws.com
echo $(make -C terraform get-app-ec2-public-dns)
echo $(make -C terraform get-mon-ec2-public-dns)
```

For now, monitoring has to be configured via UI.
