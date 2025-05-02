default:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=env-$(env)/state.tfvars
	terraform $(action) -auto-approve -var-file=env-$(env)/main.tfvars -var vault_token=$(vault_token)

dev-apply:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=env-dev/state.tfvars
	terraform apply -auto-approve -var-file=env-dev/main.tfvars -var vault_token=$(vault_token)

dev-destroy:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=env-dev/state.tfvars
	terraform destroy -auto-approve -var-file=env-dev/main.tfvars -var vault_token=$(vault_token)

prod:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=env-prod/state.tfvars
	terraform apply -auto-approve -var-file=env-prod/main.tfvars -var vault_token=$(vault_token)

prod-destroy:
	git pull
	rm -rf .terraform/terraform.tfstate
	terraform init -backend-config=env-prod/state.tfvars
	terraform destroy -auto-approve -var-file=env-prod/main.tfvars -var vault_token=$(vault_token)

clean:
	rm -rf .terraform