# Percona Monitoring and Management (PMM) Terraform


## Manual steps
1. You need to create S3 bucket: `percona-terraform`
2. You need to create SSH key: `pmm-demo`. It'll be used for connection from outside to bastion host and from bastion host to any host.

## FAQ

### Can I create multiple pmmdemo environment?

Yes you can use terraform workspaces or different AWS accounts
```
terraform workspace new demo1
```
