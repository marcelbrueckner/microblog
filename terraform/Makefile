# Basic operations
init: *.tf
	terraform init
plan: *.tf
	terraform plan
apply: *.tf
	terraform apply -auto-approve
destroy: *.tf
	terraform destroy -auto-approve

delete:
	@rm -rf output/
	@rm -rf .terraform/
	@rm -f .terraform.lock.hcl
	@rm -f terraform.tfstate
	@rm -f terraform.tfstate.backup

# "Helper targets"
get-app-ecr-repo-url:
	@terraform output -raw app_ecr_repository_url
get-app-ec2-public-dns:
	@terraform output -raw app_ec2_public_dns
get-app-ec2-id:
	@terraform output -raw app_ec2_id
get-mon-ec2-public-dns:
	@terraform output -raw mon_ec2_public_dns
get-mon-ec2-id:
	@terraform output -raw mon_ec2_id

all: init apply
clean: destroy delete