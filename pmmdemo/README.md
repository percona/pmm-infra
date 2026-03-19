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
   ```
   ssh-keygen -t ed25519 -f ~/.ssh/pmm-demo-user_ed25519_key -C "pmm-infra pmm-demo user"
   ssh-keygen -y -f ~/.ssh/pmm-demo-user_ed25519_key | awk '{print $1 " " $2}' | base64 -w0 > ~/.ssh/pmm-demo-user_ed25519_key.pub
   aws ec2 import-key-pair --key-name pmm-demo-user  --public-key-material file:///home/michael/.ssh/pmm-demo-user_ed25519_key.pub --region us-west-1
   ```
3. Update modules/ec2/data.tf aws_key_pair.key_name with the name you imported under in step #2
4. Create a file `pmmdemo/terraform.tfvars` and provide values to variables defined in `vars.tf`. Minimal configuration example:
   ```
   pmm_domain = "michael-pmmdemo.percona.net"
   owner_email = "your.name@percona.com"
   ```
5. Set the value of an environment variable called `AWS_PROFILE`. This value will be used as the default profile name for your AWS configuration. Example: `export AWS_PROFILE=dev`
6. Make sure to login to your AWS cloud account with `aws login` ahead of time.
7. Make sure to login to your Azure cloud account with `az login` ahead of time.

## Execute

1. Run `terraform workspace new XXXXX` to create a new terraform workspace. Please do not use the 'default' workspace. Example: `terraform workspace new mbpmm` Verify using `terraform workspace list`. The workspace name will be used to automatically tag any created resources.
2. Run `terraform init` to initialize your terraform state and provision terraform modules.
3. Run `terrfaform validate` to confirm your code or any change thereof are syntactically valid.
4. Run `terraform apply` to provision the infrastructure defined as code.
5. Run `terraform destroy` to tear down everything provisioned before.

Note: You can partially update(apply) or destroy resources by using the `-target` parameter. Read [more](https://learn.hashicorp.com/tutorials/terraform/resource-targeting?in=terraform/state).

## List of servers that will be privisioned

We want all VM hosts to have a DNS name so the user does not have to remember their IP addresses. When creating the host names, we append a default suffix to all of them - `*.demo.local`, where `demo` is the name of the default terraform workspace. However, if you use a non-default terraform workspace (See step #1 above), we'll append your workspace name to your hostname. For example, `*.mbpmm.local` is appended if the workspace is called `mbpmm`.

The table below provides a map of servers and their hostnames, to which the suffixes we mentioned above will be appended. For example, for Percona Server 8.0 we will provision two servers with the following hostnames, given 'mbpmm' as the workspace name:

- pecona-server-80-0.mbpmm.local
- pecona-server-80-1.mbpmm.local

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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.28.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | 3.0.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.28.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.2 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bastion"></a> [bastion](#module\_bastion) | ./modules/ec2 | n/a |
| <a name="module_bastion_disk"></a> [bastion\_disk](#module\_bastion\_disk) | ./modules/ebs | n/a |
| <a name="module_haproxy"></a> [haproxy](#module\_haproxy) | ./modules/ec2 | n/a |
| <a name="module_mongo_cluster_pmmdemo"></a> [mongo\_cluster\_pmmdemo](#module\_mongo\_cluster\_pmmdemo) | ./modules/mongo_cluster | n/a |
| <a name="module_percona_server_80"></a> [percona\_server\_80](#module\_percona\_server\_80) | ./modules/ec2 | n/a |
| <a name="module_percona_server_80_disk"></a> [percona\_server\_80\_disk](#module\_percona\_server\_80\_disk) | ./modules/ebs | n/a |
| <a name="module_percona_server_84"></a> [percona\_server\_84](#module\_percona\_server\_84) | ./modules/ec2 | n/a |
| <a name="module_percona_server_84_disk"></a> [percona\_server\_84\_disk](#module\_percona\_server\_84\_disk) | ./modules/ebs | n/a |
| <a name="module_percona_server_84_gr"></a> [percona\_server\_84\_gr](#module\_percona\_server\_84\_gr) | ./modules/ec2 | n/a |
| <a name="module_percona_server_84_gr_disk"></a> [percona\_server\_84\_gr\_disk](#module\_percona\_server\_84\_gr\_disk) | ./modules/ebs | n/a |
| <a name="module_percona_xtradb_cluster_80"></a> [percona\_xtradb\_cluster\_80](#module\_percona\_xtradb\_cluster\_80) | ./modules/ec2 | n/a |
| <a name="module_percona_xtradb_cluster_80_disk"></a> [percona\_xtradb\_cluster\_80\_disk](#module\_percona\_xtradb\_cluster\_80\_disk) | ./modules/ebs | n/a |
| <a name="module_pmm_server"></a> [pmm\_server](#module\_pmm\_server) | ./modules/ec2 | n/a |
| <a name="module_pmm_server_disk"></a> [pmm\_server\_disk](#module\_pmm\_server\_disk) | ./modules/ebs | n/a |
| <a name="module_postgresql_16"></a> [postgresql\_16](#module\_postgresql\_16) | ./modules/ec2 | n/a |
| <a name="module_postgresql_16_disk"></a> [postgresql\_16\_disk](#module\_postgresql\_16\_disk) | ./modules/ebs | n/a |
| <a name="module_proxysql"></a> [proxysql](#module\_proxysql) | ./modules/ec2 | n/a |
| <a name="module_sysbench"></a> [sysbench](#module\_sysbench) | ./modules/ec2 | n/a |
| <a name="module_valkey"></a> [valkey](#module\_valkey) | ./modules/ec2 | n/a |
| <a name="module_ycsb"></a> [ycsb](#module\_ycsb) | ./modules/ec2 | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.rds_mysql_80](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.database_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_default_security_group.pmmdemo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.external_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_access_key.rds_user_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_instance_profile.pmmdemo_ec2_rds_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.pmmdemo_rds_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.pmmdemo_rds_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.pmmdemo_rds_role_attachement](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.pmmdemo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.external_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route53_record.pmmdemo_hostname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.demo_local](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route_table.ig_pmmdemo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.nat_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.associate_routetable_to_private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.associate_routetable_to_private_subnet_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.pmmdemo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.aurora_engine](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.default_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_external_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.allow_private_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.pmmdemo_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.pmmdemo_private_a](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.pmmdemo_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.pmmdemo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_dhcp_options.additional_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options) | resource |
| [aws_vpc_dhcp_options_association.vpc_dhcp_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_dhcp_options_association) | resource |
| [random_password.mongodb_ycsb_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.mysql80_replica_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.mysql80_root_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.mysql80_sysbench_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.mysql84_replica_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.mysql84_root_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.mysql84_sysbench_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.percona_server_84_gr_root_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.percona_server_84_gr_sysbench_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.percona_xtradb_cluster_80_root_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.percona_xtradb_cluster_80_sysbench_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.pmm_admin_pass](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.postgresql_16_pmm_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.postgresql_16_sysbench_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.proxysql_admin](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.proxysql_monitor](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.rds_mysql_80_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_password.valkey_primary_password](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/password) | resource |
| [random_uuid.percona_server_84_gr_uuid](https://registry.terraform.io/providers/hashicorp/random/3.4.2/docs/resources/uuid) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_user.rds_user](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_user) | data source |
| [aws_route53_zone.pmmdemo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_secretsmanager_secret.sso_creds_mgr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.sso_creds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [template_file.percona_server_80_user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.percona_server_84_gr_user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.percona_server_84_user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.percona_xtradb_cluster_80_user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_DBAAS"></a> [DBAAS](#input\_DBAAS) | Control whether to deploy the RDS cluster (0 = no, 1 = yes) | `number` | `1` | no |
| <a name="input_google_analytics_id"></a> [google\_analytics\_id](#input\_google\_analytics\_id) | Google Analytics tracking code | `string` | `"UA-343802-29"` | no |
| <a name="input_oauth_api_url"></a> [oauth\_api\_url](#input\_oauth\_api\_url) | Oauth API URL | `string` | `"https://id.percona.com/oauth2/auskl7vxt4N1CAbjO1t7/v1/userinfo"` | no |
| <a name="input_oauth_enable"></a> [oauth\_enable](#input\_oauth\_enable) | Use oauth to connect PMM to the Portal | `bool` | `true` | no |
| <a name="input_oauth_role_attribute_path"></a> [oauth\_role\_attribute\_path](#input\_oauth\_role\_attribute\_path) | Oauth Attribute path | `string` | `"pmm_demo_role"` | no |
| <a name="input_oauth_scopes"></a> [oauth\_scopes](#input\_oauth\_scopes) | scope for auth | `string` | `"openid profile email offline_access percona"` | no |
| <a name="input_oauth_signout_redirect_url"></a> [oauth\_signout\_redirect\_url](#input\_oauth\_signout\_redirect\_url) | Oauth Signout Redirect URL | `string` | `"https://id.percona.com/login/signout?fromURI=https://pmmdemo.percona.com/graph/login"` | no |
| <a name="input_oauth_token_url"></a> [oauth\_token\_url](#input\_oauth\_token\_url) | Oauth token URL | `string` | `"https://id.percona.com/oauth2/auskl7vxt4N1CAbjO1t7/v1/token"` | no |
| <a name="input_oauth_url"></a> [oauth\_url](#input\_oauth\_url) | Oauth auth url | `string` | `"https://id.percona.com/oauth2/auskl7vxt4N1CAbjO1t7/v1/authorize"` | no |
| <a name="input_owner_email"></a> [owner\_email](#input\_owner\_email) | Email for letsencrypt account | `string` | n/a | yes |
| <a name="input_pmm_domain"></a> [pmm\_domain](#input\_pmm\_domain) | PMM domain name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Do not use 'default' namespace | `string` | `"mypmmdemo123"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mongodb_60_percona_admin_password"></a> [mongodb\_60\_percona\_admin\_password](#output\_mongodb\_60\_percona\_admin\_password) | n/a |
| <a name="output_mongodb_60_pmm_user_password"></a> [mongodb\_60\_pmm\_user\_password](#output\_mongodb\_60\_pmm\_user\_password) | n/a |
| <a name="output_mongodb_ycsb_password"></a> [mongodb\_ycsb\_password](#output\_mongodb\_ycsb\_password) | n/a |
| <a name="output_percona_server_80_password"></a> [percona\_server\_80\_password](#output\_percona\_server\_80\_password) | n/a |
| <a name="output_percona_server_84_gr_root_password"></a> [percona\_server\_84\_gr\_root\_password](#output\_percona\_server\_84\_gr\_root\_password) | n/a |
| <a name="output_percona_server_84_gr_sysbench_password"></a> [percona\_server\_84\_gr\_sysbench\_password](#output\_percona\_server\_84\_gr\_sysbench\_password) | n/a |
| <a name="output_percona_server_84_password"></a> [percona\_server\_84\_password](#output\_percona\_server\_84\_password) | n/a |
| <a name="output_percona_xtradb_cluster_80_root_password"></a> [percona\_xtradb\_cluster\_80\_root\_password](#output\_percona\_xtradb\_cluster\_80\_root\_password) | n/a |
| <a name="output_percona_xtradb_cluster_80_sysbench_password"></a> [percona\_xtradb\_cluster\_80\_sysbench\_password](#output\_percona\_xtradb\_cluster\_80\_sysbench\_password) | n/a |
| <a name="output_pmm_admin_pass"></a> [pmm\_admin\_pass](#output\_pmm\_admin\_pass) | n/a |
| <a name="output_postgresql_16_pmm_password"></a> [postgresql\_16\_pmm\_password](#output\_postgresql\_16\_pmm\_password) | n/a |
| <a name="output_postgresql_16_sysbench_password"></a> [postgresql\_16\_sysbench\_password](#output\_postgresql\_16\_sysbench\_password) | n/a |
| <a name="output_proxysql_admin_password"></a> [proxysql\_admin\_password](#output\_proxysql\_admin\_password) | n/a |
| <a name="output_proxysql_monitor_password"></a> [proxysql\_monitor\_password](#output\_proxysql\_monitor\_password) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
| <a name="output_rds_mysql_80_password"></a> [rds\_mysql\_80\_password](#output\_rds\_mysql\_80\_password) | output "rds\_postgresql\_16\_password" { value     = random\_password.rds\_postgresql\_16\_password.result sensitive = true } |
<!-- END_TF_DOCS -->
