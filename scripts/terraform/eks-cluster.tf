#
# Creates a managed Kubernetes cluster on AWS.
#

# Create IAM role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com",
          "AWS": "arn:aws:iam::${var.aws_account_id}:user/${var.aws_iam_user}"
        }
      }
    ]
  })

  tags = {
    ResourceGroupName = var.resource_group_name
  }
}

# Attach the EKS Cluster Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# # Attach the EKS  SVPC Resourse Controller to the IAM Role
resource "aws_iam_role_policy_attachment" "eks_svpc_reource_controller" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Attach the EKS Worker Node Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Create the EKS Cluster using VPC and subnets
resource "aws_eks_cluster" "sit722week10" {
  name  = "sit722week10"
  role_arn = aws_iam_role.eks_cluster_role.arn

  depends_on = [
    aws_vpc.sit722week10,
    aws_iam_role.eks_cluster_role,
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment,
    aws_iam_role_policy_attachment.eks_svpc_reource_controller,
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    ]

  vpc_config {
    subnet_ids = aws_subnet.publicsubnet[*].id
    endpoint_private_access = true
  }

  tags = {
    ResourceGroupName = var.resource_group_name
  }
}

# IAM role for Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name = "eks_node_group_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the EKS Worker Node Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach the EKS CNI Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


# Attach the EKS ECR read only Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "ecr_readonly_policy_attachment" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Define the EKS cluster data source to obtain the cluster endpoint and CA certificate
data "aws_eks_cluster" "eks_cluster" {
  name = aws_eks_cluster.sit722week10.name
}

# Define the EKS cluster authentication data source to obtain the authentication token
data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = data.aws_eks_cluster.eks_cluster.name
}

# Configure Kubernetes Provider to connect to EKS Cluster
provider "kubernetes" {
  host = aws_eks_cluster.sit722week10.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.sit722week10.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.eks_cluster_auth.token
}