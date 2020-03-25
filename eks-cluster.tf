#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EKS Cluster

resource "aws_iam_role" "vb-cluster" {
  name = "${var.cluster-name}-EKSServiceMgmt"

  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "vb-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.vb-cluster.name
}

resource "aws_iam_role_policy_attachment" "vb-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.vb-cluster.name
}


resource "aws_eks_cluster" "vb" {
  name     = var.cluster-name
  role_arn = aws_iam_role.vb-cluster.arn
  version  = "1.15"

  vpc_config {
    security_group_ids = [aws_security_group.vb-cluster.id]
    subnet_ids         = concat(aws_subnet.vb-public[*].id, aws_subnet.vb-private[*].id)
  }

  depends_on = [
    aws_iam_role_policy_attachment.vb-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.vb-cluster-AmazonEKSServicePolicy,
  ]
}
