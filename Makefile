default:
	rm -rf .terraform
	terraform init -backend-config=env-$(env)/state.tfvars
	terraform $(action) -auto-approve -var-file=env-$(env)/main.tfvars -var vault_token=$(vault_token)

dev-apply:
	rm -rf .terraform
	terraform init -backend-config=env-dev/state.tfvars
	terraform apply -auto-approve -var-file=env-dev/main.tfvars -var vault_token=$(vault_token)

dev-destroy:
	rm -rf .terraform
	terraform init -backend-config=env-dev/state.tfvars
	terraform destroy -auto-approve -var-file=env-dev/main.tfvars -var vault_token=$(vault_token)

prod:
	rm -rf .terraform
	terraform init -backend-config=env-prod/state.tfvars
	terraform apply -auto-approve -var-file=env-prod/main.tfvars -var vault_token=$(vault_token)

prod-destroy:
	rm -rf .terraform
	terraform init -backend-config=env-prod/state.tfvars
	terraform destroy -auto-approve -var-file=env-prod/main.tfvars -var vault_token=$(vault_token)