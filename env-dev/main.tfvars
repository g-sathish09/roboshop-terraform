env         = "dev"
domain_name = "harsharoboticshop.online"
zone_id     = "Z05536047CUMASJ01KSK"

db_instances = {
  mongodb = {
    app_port      = 27017
    instance_type = "t3.small"
    volume_size   = 20
  }

  redis = {
    app_port      = 6379
    instance_type = "t3.small"
    volume_size   = 20
  }

  rabbitmq = {
    app_port      = 5672
    instance_type = "t3.small"
    volume_size   = 20
  }

  mysql = {
    app_port      = 3306
    instance_type = "t3.small"
    volume_size   = 20
  }
 }

 app_instances = {

  catalogue = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = 30
  }

  cart = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = 30
  }

  user = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = 30
  }

  shipping = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = 30
  }

  payment = {
    app_port      = 8080
    instance_type = "t3.small"
    volume_size   = 30
  }

}

web_instances = {
  frontend = {
    app_port      = 80
    instance_type = "t3.small"
    volume_size   = 20
  }
}

# eks = {
#   subnet_ids = ["subnet-0792461b5224de598", "subnet-033b518ba99521b88"]
#   addons = {
#     vpc-cni = {}
#     kube-proxy = {}
#   }
#
#   access_entries = {
#     workstation = {
#       principal_arn     = "arn:aws:iam::897722697588:role/workstation-role"
#       kubernetes_groups = []
#       policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#       access_scope_type = "cluster"
#       access_scope_namespaces = []
#     }
#     # UI Access
#     ui-access = {
#       principal_arn     = "arn:aws:iam::897722697588:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_DevOpsEngineers_70a51c5bd23375d3"
#       kubernetes_groups = []
#       policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
#       access_scope_type = "cluster"
#       access_scope_namespaces = []
#     }
#   }
#
#   node_groups = {
#     g1 = {
#       desired_size  = 1
#       max_size      = 2
#       min_size      = 1
#       capacity_type = "SPOT"
#       instance_types = ["t3.large"]
#     }
#   }
# }