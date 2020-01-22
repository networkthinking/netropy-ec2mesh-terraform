# netropy-ec2mesh-terraform

## Install Terraform
https://learn.hashicorp.com/terraform/getting-started/install.html

## Deploy the environment
1. edit terraform.tfvars
2. run `terraform init`
3. run `terraform apply`
4. run `./post-setup.sh`

This will provision 2 application instances and 1 netropy instance. The output from terraform would show something like this:
```
Apply complete! Resources: 23 added, 0 changed, 0 destroyed.

Outputs:

netropy_address = http://52.43.188.122
netropy_password = i-060dffc8c5b6482c4
```
