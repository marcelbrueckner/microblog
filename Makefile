.DEFAULT_GOAL := all

# Create infrastructure using Terraform
# Uses Makefile in terraform/ folder
infra: terraform/*.tf
	@$(MAKE) -C terraform all
infra-clean: terraform/*.tf
	@$(MAKE) -C terraform clean

# Build and push Docker container
build: export AWS_ECR_REPO=$(shell $(MAKE) -C terraform get-app-ecr-repo-url)
build:
	@$(MAKE) -C microblog all
build-clean:
	@$(MAKE) -C microblog clean

# Deploy application to VM
deploy-prepare: terraform/output/ansible/hosts.ini
	cp -R terraform/output/ansible/* ansible/
deploy-execute:
	@$(MAKE) -C ansible all
deploy-clean:
	@$(MAKE) -C ansible clean
deploy: deploy-prepare deploy-execute

all: infra build wait deploy
clean: infra-clean deploy-clean

# Helper
ssh-app: export AWS_EC2_HOST=$(shell $(MAKE) -C terraform get-app-ec2-public-dns)
ssh-app:
	@ssh -i terraform/output/ansible/private.pem centos@${AWS_EC2_HOST} -o StrictHostKeyChecking=no
ssh-mon: export AWS_EC2_HOST=$(shell $(MAKE) -C terraform get-mon-ec2-public-dns)
ssh-mon:
	@ssh -i terraform/output/ansible/private.pem centos@${AWS_EC2_HOST} -o StrictHostKeyChecking=no
# When running all at once, it looks like AWS security group rules need some time to be effective
wait:
	sleep 60
