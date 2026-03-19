data "terraform_remote_state" "pmm" {
  backend = "s3"
  config = {
    bucket = "percona-terraform"
    key    = "pmm.tfstate"
    region = "us-east-1"
  }
}
