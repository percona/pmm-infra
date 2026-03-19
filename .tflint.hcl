plugin "aws" {
    enabled = true
    version = "0.26.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

rule "terraform_required_version" {
    enabled = true
}

rule "terraform_required_providers" {
    enabled = true
}

rule "terraform_unused_declarations" {
    enabled = true
}
