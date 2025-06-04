resource "aws_iam_role" "eks-cluster-role" {
  name = "${var.env}-eks-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "main-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster-role.name
}


resource "aws_iam_role" "eks-node-group-role" {
  name = "${var.env}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "main-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "main-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node-group-role.name
}

resource "aws_iam_role_policy_attachment" "main-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node-group-role.name
}


resource "aws_iam_role" "external-dns" {
  name = "${var.env}-eks-external-dns-pod"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "pods.eks.amazonaws.com"
          ]
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  inline_policy {
    name = "external-dns-policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets",
            "route53:ListTagsForResource"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    })
  }


}

resource "aws_eks_pod_identity_association" "external-dns" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "devops"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external-dns.arn
}


resource "aws_iam_role" "cluster-autoscaler" {
  name = "${var.env}-eks-cluster-autoscaler-pod"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : [
            "pods.eks.amazonaws.com"
          ]
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  inline_policy {
    name = "cluster-autoscaler-policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "autoscaling:DescribeAutoScalingGroups",
            "autoscaling:DescribeAutoScalingInstances",
            "autoscaling:DescribeLaunchConfigurations",
            "autoscaling:DescribeScalingActivities",
            "ec2:DescribeImages",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeLaunchTemplateVersions",
            "ec2:GetInstanceTypesFromInstanceRequirements",
            "eks:DescribeNodegroup"
          ],
          "Resource" : ["*"]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "autoscaling:SetDesiredCapacity",
            "autoscaling:TerminateInstanceInAutoScalingGroup"
          ],
          "Resource" : ["*"]
        }
      ]
    })
  }
}

resource "aws_eks_pod_identity_association" "cluster-autoscaler-dns" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "devops"
  service_account = "cluster-autoscaler-aws-cluster-autoscaler"
  role_arn        = aws_iam_role.cluster-autoscaler.arn
}