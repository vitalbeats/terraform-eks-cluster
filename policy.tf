resource "aws_iam_policy" "vb-cluster" {
    name = "${var.cluster-name}-kubeconfig"
    description = "Allows access to kubeconfig for ${var.cluster-name} EKS cluster"

    policy =<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:aws:eks:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${var.cluster-name}"
        },
        {
            "Effect": "Allow",
            "Action": "eks:ListClusters",
            "Resource": "*"
        }
    ]
}
EOF
}
