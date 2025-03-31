provider "vault" {
  address         = "http://vault-internal.harsharoboticshop.online:8200"
  token           = var.vault_token
  skip_tls_verify = true
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}