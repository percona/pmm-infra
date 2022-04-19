# Percona Monitoring and Management (PMM) Demo (pmmdemo)

This project aims at providing a convenient means to streamline the provisioning
of a PMM Server that allows to monitor and manage a number of different databases, including
those deployed on major public cloud environments.

The project is based on the battle-tested Hashicorp's [terraform](https://www.terraform.io) tool,
which has proven its effectiveness in many other open-source projects.

We stick to Infrastructure as a Code (IaC) approach, which means that all of the provisioning
logic is expressed in the code. This makes it easy to audit the project, learn from it and, finally,
gives people a chance to improve it.

This project may help in the following use cases:

- explore an environment where PMM Server is provisioned with a variety of databases
- experiment with something we don't currently offer out-of-the-box, for example a new datasource or database

## Tools to install

To be able to run terraform scripts you need to install the following tools:

| Name      | Install command        | Run as    |
| --------- | ---------------------- | --------- |
| terraform | brew install terraform | terraform |
| aws cli   | brew install awscli    | aws       |
| azure cli | brew install azure-cli | az        |

The `install` commands we provided above are only suitable for MacOS, but we believe it's not difficult to find
their counterparts for a different operating systems given that `terraform` is widely supported.

## Prepare

To prepare for a successul launch of pmmdemo infrastructure, please follow the instruction below:

1. Create an S3 bucket `percona-terraform`, which will be used to store intermediary state.
2. Create an SSH key `pmm-demo`, which will be used to connect from outside to the bastion host. The bastion host
   is one entry point from which you can connect to other hosts. Apart from the bastion, all other hosts do not
   expose public IP addresses.
3. Create a file `pmmdemo/terraform.tfvars` with two variables, for example:
   - pmm_domain = "pmmdemo.percona.net"
   - owner_email = "your.name@percona.com"
4. Copy `.envrc.template` to `.envrc` and set a value for `AWS_PROFILE`. This value will be used as the
   default profile name for your AWS configuration.
5. Make sure to login to your AWS cloud account with `aws login` ahead of time.
6. Make sure to login to your Azure cloud account with `az login` ahead of time.

## Execute

1. Run `direnv allow` to inject the variables from `.envrc` file to your environment.
2. Run `terraform init` to initialize your terraform state.GitHub Pull Requests and Issues

## FAQ

### Can I create multiple pmmdemo environments?

Yes, you can use terraform workspaces or different AWS accounts.

```
terraform workspace new demo1
```
