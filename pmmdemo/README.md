# Percona Monitoring and Management (PMM) Demo - pmmdemo

This project aims at providing a convenient means to streamline the provisioning of a PMM Server that allows to monitor and manage a number of different databases, including those deployed on major public cloud environments.

The project is based on the battle-tested Hashicorp's [terraform](https://www.terraform.io) tool,
which has proven its effectiveness in many other open-source projects.

We stick to Infrastructure as a Code (IaC) approach, which means that all of the provisioning logic is in the code. This makes it easy to audit the project, learn from it and, finally, gives people a chance to improve it.

This project may help in the following use cases:

- explore an environment where PMM Server is provisioned with a variety of databases
- experiment with something we don't currently offer out-of-the-box, for example a new datasource or database

## Tools to install (CLI)

To be able to run terraform scripts provided in this folder you need to install the following tools:

| Name      | Install command        | Run as    |
| --------- | ---------------------- | --------- |
| terraform | brew install terraform | terraform |
| aws cli   | brew install awscli    | aws       |
| azure cli | brew install azure-cli | az        |

The `install` commands we provided above are only suitable for MacOS, but we believe it's not difficult to find
their counterparts for different operating systems given that these tools or CLIs are very popular.

## Prepare

To prepare for a successul launch of pmmdemo infrastructure, please follow the instructions below:

1. Create an S3 bucket `percona-terraform`, which will be used to store intermediary terraform state.
2. Create an SSH key `pmm-demo`, which will be used to connect from outside to the bastion host. The bastion host
   is one entry point from which you can connect to other hosts. Apart from the bastion, all other hosts do not
   expose public IP addresses.
3. Create a file `pmmdemo/terraform.tfvars` and provide values to variables defined in `vars.tf`. Minimal configuration example:
   ```
   pmm_domain = "pmmdemo.percona.net"
   owner_email = "your.name@percona.com"
   ```
4. Set the value of an environment variable called `AWS_PROFILE`. This value will be used as the default profile name for your AWS configuration. Example: `export AWS_PROFILE=dev`
5. Make sure to login to your AWS cloud account with `aws login` ahead of time.
6. Make sure to login to your Azure cloud account with `az login` ahead of time.

## Execute

1. Run `terraform init` to initialize your terraform state and provision terraform modules.
2. Run `terrfaform validate` to confirm your code or any change thereof are syntactically valid.
3. Run `terraform apply` to provision the infrastructure defined as code.
4. Run `terraform destroy` to tear down everything provisioned before.

Note: You can partially update(apply) or destroy resources by using the `-target` parameter. Read [more](https://learn.hashicorp.com/tutorials/terraform/resource-targeting?in=terraform/state).

## List of servers that will be privisioned

We want all VM hosts to have a DNS name so the user does not have to remember their IP addresses. When creating the host names, we append a default suffix to all of them - `*.demo.local`, where `demo` is the name of the default terraform workspace. However, if you use a non-default terraform workspace, we'll append your workspace name to your hostname. For example, `*.test.local` is appended if the workspace is called `test`.

The table below provides a map of servers and their hostnames, to which the suffixes we mentioned above will be appended. For example, for Percona Server 8.0 we will provision two servers with the following hostnames (in case of default workspace name):

- pecona-server-80-0.demo.local
- pecona-server-80-1.demo.local

### Databases

| Name                       | Hostnames                                                         | Workload |
| -------------------------- | ----------------------------------------------------------------- | -------- |
| Azure MySQL 8.0            | pmmdemo-azure                                                     |          |
| AWS MySQL 8.0              | pmmdemo-mysql                                                     |          |
| AWS Postgres 13            | pmmdemo-postgres                                                  |          |
| AWS Aurora 2               | pmmdemo-aurora-cluster                                            |          |
| MongoDB 6.0                | mongo-60-cfg-? (0,1,2), mongo-60-rs-?-? (0,1,2), mongo60-mongos-0 |          |
| Percona XtraDB Cluster 8.0 | percona-xtradb-cluster-? (0,1,2)                                  | yes      |
| Percona Server 8.0         | percona-server-80-? (0,1)                                         | yes      |
| Percona Server for PG 13   | postgres-13                                                       | yes      |

### Other servers

| Name         | Hostname   | Notes                                                |
| ------------ | ---------- | ---------------------------------------------------- |
| ProxySQL     | proxysql   | Proxy for Percona XtraDB Cluster                     |
| HAProxy      | haproxy    | Proxy for Percona XtraDB Cluster                     |
| Sysbench     | sysbench   | Sysbench instances to provide workloads for some DBs |
| PMM Server   | pmm-server | PMM Server instance                                  |
| Bastion host | bastion    | nginx + ssh access point                             |

## FAQ

### Can I create multiple pmmdemo environments?

Yes, you can use terraform workspaces or different AWS profiles.

```
# aws dev profile
export AWS_PROFILE=dev
terraform workspace new demo1
terraform init
terraform apply # demo1, profile=dev
...
# aws prod profile
export AWS_PROFILE=prod
terraform workspace new demo2
terraform init
terraform apply # demo2, profile=prod
...
# then later...
terraform destroy # demo2, profile=prod
export AWS_PROFILE=dev
terraform workspace select demo1
terraform destroy # demo1, profile=dev
```

### I need to be able to output my passwords when troubleshooting connectivity issues. Can I?

Yes. Run the following command: `terraform output -json | jq`.

### How do I force a member of a MongoDB replicaset to become a primary?

Refer to the [manual] (https://www.mongodb.com/docs/manual/tutorial/force-member-to-be-primary/).

A few links to the docs of the respective servers we used to monitor:

- https://docs.percona.com/percona-xtradb-cluster/8.0/howtos/centos_howto.html
