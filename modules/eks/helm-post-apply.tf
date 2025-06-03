# This file contains resources that will be applied after the cluster is created
# These resources are separated to avoid the "cluster unreachable" error during plan

locals {
  helm_charts_enabled = false # Set to true when you want to apply Helm charts
}

resource "null_resource" "helm_charts" {
  count = local.helm_charts_enabled ? 1 : 0
  
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main
  ]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${var.env}-eks --region $(aws configure get region)
      
      # Create namespace
      kubectl create namespace devops --dry-run=client -o yaml | kubectl apply -f -
      kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
      
      # Install metrics server
      kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
      
      # Install nginx-ingress
      helm upgrade --install nginx-ingress oci://ghcr.io/nginxinc/charts/nginx-ingress \
        --namespace devops \
        --values ${path.module}/helm-config/nginx-ingress.yml \
        --wait
      
      # Install external-dns
      helm upgrade --install external-dns \
        --namespace devops \
        --repo https://kubernetes-sigs.github.io/external-dns \
        external-dns
      
      # Install ArgoCD
      helm upgrade --install argocd \
        --namespace argocd \
        --repo https://argoproj.github.io/argo-helm \
        argo-cd \
        --set global.domain=argocd-${var.env}.harsharoboticshop.online \
        --values ${path.module}/helm-config/argocd.yml
      
      # Install Prometheus Stack
      helm upgrade --install prometheus \
        --namespace devops \
        --repo https://prometheus-community.github.io/helm-charts \
        kube-prometheus-stack \
        --values ${path.module}/helm-config/prom-stack.yml
      
      # Install External Secrets
      helm upgrade --install external-secrets \
        --namespace devops \
        --repo https://charts.external-secrets.io \
        external-secrets \
        --wait
      
      # Configure External Secrets
      kubectl apply -f - <<EOK
apiVersion: v1
kind: Secret
metadata:
  name: vault-token
data:
  token: aHZzLnFjMlY5NElNQ2hPQ2RvSkxvM3FlckRReQ==
---
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "http://vault-internal.harsharoboticshop.online:8200"
      path: "roboshop-${var.env}"
      version: "v2"
      auth:
        tokenSecretRef:
          name: "vault-token"
          key: "token"
EOK
      
      # Install Filebeat
      helm upgrade --install filebeat \
        --namespace kube-system \
        --repo https://helm.elastic.co \
        filebeat \
        --values ${path.module}/helm-config/filebeat.yaml
      
      # Install Cluster Autoscaler
      helm upgrade --install cluster-autoscaler \
        --namespace devops \
        --repo https://kubernetes.github.io/autoscaler \
        cluster-autoscaler \
        --set autoDiscovery.clusterName=${aws_eks_cluster.main.name}
    EOT
  }
}