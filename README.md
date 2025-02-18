# Infrastructure as Code - Sandbox

Repo for several Infrastructure as Code (IaC) projects.

## Terraform instructions

```bash
# Downloads plugins, startups needed systems
terraform init

# Shows planned infrastructure
terraform plan

# Creates infrastructure
terraform apply

# Destroys infrastructure
terraform destroy

# Validate configuration syntax
terraform validate

# Format files
terraform fmt

# Show created resources
terraform show

# Check Providers
terraform providers

# Copy provider initialization to different directory
terraform providers mirror /path/to/

# State-related

terraform state list

# example: local_file.classics
terraform state show <resource-name>

# example: local_file.hall_of_fame
terraform state rm <resource-name>

# example: terraform state mv random_pet.pet1 random_pet.pet2
terraform state mv <old-resource-name> <new-resource-name>

# Enable logs
# Values = INFO WARNING ERROR, DEBUG TRACE
export TF_LOG=<value>

# Sets location where to export logs
export TF_LOG_PATH=<value>

# Taint resource
terraform taint <resource>

# Untaint resource
terraform untaint <resource>
```
