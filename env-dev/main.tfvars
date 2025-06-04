env         = "dev"
domain_name = "harsharoboticshop.online"
zone_id     = "Z05536047CUMASJ01KSK"
bastion_nodes = ["172.31.91.184/32", "172.31.83.166/32"]

db_instances = {
  mongodb = {
    app_port      = 27017
    instance_type = "t3.small"
    volume_size   = 20
    allow_cidr    = ["10.0.0.128/26", "10.0.0.192/26"]
  }

  redis = {
    app_port      = 6379
    instance_type = "t3.small"
    volume_size   = 20
    allow_cidr    = ["10.0.0.128/26", "10.0.0.192/26"]
  }

  rabbitmq = {
    app_port      = 5672
    instance_type = "t3.small"
    volume_size   = 20
    allow_cidr    = ["10.0.0.128/26", "10.0.0.192/26"]
  }

  mysql = {
    app_port      = 3306
    instance_type = "t3.small"
    volume_size   = 20
    allow_cidr    = ["10.0.0.128/26", "10.0.0.192/26"]
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

eks = {
  addons = {
    vpc-cni = {}
    kube-proxy = {}
    eks-pod-identity-agent = {}

  }

  access_entries = {
    workstation = {
      principal_arn           = "arn:aws:iam::975050062321:role/github-runner-role"
      kubernetes_groups       = []
      policy_arn              = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      access_scope_type       = "cluster"
      access_scope_namespaces = []
    }
    # UI Access
    ui-access = {
      principal_arn           = "arn:aws:iam::975050062321:root"
      kubernetes_groups       = []
      policy_arn              = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
      access_scope_type       = "cluster"
      access_scope_namespaces = []
    }
  }


  node_groups = {
    g1 = {
      desired_size = 2
      max_size     = 10
      min_size     = 2
      capacity_type = "SPOT"
      instance_types = ["t3.large"]
    }
  }
}

vpc = {
  main = {
    cidr_block = "10.0.0.0/24"
    subnets = {
      public-subnet-1 = {
        cidr_block   = "10.0.0.0/27"
        az           = "us-east-1a"
        igw          = true
        subnet_group = "public"
      }
      public-subnet-2 = {
        cidr_block   = "10.0.0.32/27"
        az           = "us-east-1b"
        igw          = true
        subnet_group = "public"
      }
      db-subnet-1 = {
        cidr_block   = "10.0.0.64/27"
        az           = "us-east-1a"
        igw          = false
        subnet_group = "db"
      }
      db-subnet-2 = {
        cidr_block   = "10.0.0.96/27"
        az           = "us-east-1b"
        igw          = false
        subnet_group = "db"
      }
      app-subnet-1 = {
        cidr_block   = "10.0.0.128/26"
        az           = "us-east-1a"
        igw          = false
        subnet_group = "app"
      }
      app-subnet-2 = {
        cidr_block   = "10.0.0.192/26"
        az           = "us-east-1b"
        igw          = false
        subnet_group = "app"
      }
    }
  }

}

default_vpc = {
  id          = "vpc-05b09be73f5c07d64"
  cidr        = "172.31.0.0/16"
  route_table = "rtb-01ab7225851bf4a02"
}