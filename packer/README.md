# Packer templates to build the agents on AWS and DigitalOcean

### Building agents

- AWS: `packer build aws.pkr.hcl`
- DigitalOcean: `packer build -color=false do.pkr.hcl`

### To bebug

Run `PACKER_LOG_PATH="packerlog.txt" PACKER_LOG=1 packer build do.pkr.hcl`
