# tf-code

Terraform is a DevOps tool made by HashiCorp for declarative infrastructure — infrastructure as code which simplifies and accelerates the configuration of cloud-based environments. 

It can be used with several cloud providers like Amazon Web Services (AWS), Microsoft Azure, Google Cloud Platform (GCP), etc.

Terraform manages your infrastructure, as well as use core Terraform commands.

Identity and Access Management (IAM) is essential with Terraform so that accesses to cloud-provider resources are possible.

**Commands:**

- `terraform init` - used to initialize a working directory that contains Terraform config files
- `terraform apply` - used to create or update your infrastructure
- `terraform plan` - used to call out to your cloud-provider to retrieve the state of a specific resource you are comparing to

### How to not INCUR charges 
- `terraform plan -destroy` -  shows the resources that will be destroyed when you apply the `destroy` command
- `terraform plan -destroy -out=destroy.plan` - saves the outcome of the `terraform plan -destroy` to a file called `destroy.plan` or whatever name you choose to call it.
