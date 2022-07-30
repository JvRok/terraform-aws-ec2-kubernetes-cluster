# Examples

Shows how to use the module
At this point, sourced locally as it is not uploaded to the main terraform registry

1. Log into the AWS CLI.
2. Create a tfvars file, either default (terraform.tfvars) or custom, and supply the ssh key. (See example.tfvars for the values that are required)

```bash windows
#!/bin/bash
terraform init
terraform apply
```

alternatively use a custom names tfvars file:

```bash windows
#!/bin/bash
terraform init
terraform apply -var-file=<tfvarsfile>.tf
```

Variables are defaulted in sub-modules, as well as root module, but can be overwritten as in examples/main.tf
