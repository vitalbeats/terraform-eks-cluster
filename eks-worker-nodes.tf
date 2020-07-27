#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "vb-node" {
  name               = "${var.cluster-name}-AWSServices"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "vb-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.vb-node.name
}

resource "aws_iam_role_policy_attachment" "vb-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vb-node.name
}

resource "aws_iam_role_policy_attachment" "vb-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.vb-node.name
}

resource "aws_eks_node_group" "ng-workers" {
  cluster_name    = aws_eks_cluster.vb.name
  node_group_name = "ng-workers"
  node_role_arn   = aws_iam_role.vb-node.arn
  subnet_ids      = aws_subnet.vb-public[*].id
  instance_types  = ["t3.xlarge"]
  ec2_ssh_key     = var.ec2-ssh-key

  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.vb-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.vb-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.vb-node-AmazonEC2ContainerRegistryReadOnly
  ]
}
