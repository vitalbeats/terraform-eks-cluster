resource "null_resource" "calico" {
  count = var.enable-calico ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-1.5/config/v1.5/calico.yaml --kubeconfig ${path.cwd}/output/${var.cluster-name}/kubeconfig-${var.cluster-name}"
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }

  depends_on = [aws_eks_node_group.ng-workers, null_resource.kubectl]
}

resource "null_resource" "dashboard" {
  count = var.enable-dashboard ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-rc5/aio/deploy/recommended.yaml --kubeconfig ${path.cwd}/output/${var.cluster-name}/kubeconfig-${var.cluster-name}"
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }

  depends_on = [aws_eks_node_group.ng-workers, null_resource.kubectl]
}

resource "null_resource" "ingress" {
  count = var.enable-ingress ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/deploy-ingress.sh ${path.cwd}/output/${var.cluster-name}/kubeconfig-${var.cluster-name} ${var.ingress-acm-arn}"
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
    acm_chosen = var.ingress-acm-arn
  }

  depends_on = [aws_eks_node_group.ng-workers, null_resource.kubectl]
}

resource "null_resource" "letsencrypt" {
  count = var.enable-letsencrypt ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml --kubeconfig ${path.cwd}/output/${var.cluster-name}/kubeconfig-${var.cluster-name}"
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }

  depends_on = [aws_eks_node_group.ng-workers, null_resource.kubectl]
}

resource "null_resource" "letsencrypt-config" {
  count = var.enable-letsencrypt ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/letsencrypt-config.sh ${path.cwd}/output/${var.cluster-name}/kubeconfig-${var.cluster-name} ${var.letsencrypt-email}"
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }

  depends_on = [aws_eks_node_group.ng-workers, null_resource.kubectl, null_resource.letsencrypt]
}

resource "kubernetes_namespace" "secrets-manager" {
  count = var.enable-secrets-manager ? 1 : 0

  metadata {
    name = "aws-secrets-manager"
  }
}

locals {
  oidc_provider = trimprefix(aws_eks_cluster.vb.identity.0.oidc.0.issuer, "https://")
}

resource "aws_iam_role" "secrets-manager-role" {
  count       = var.enable-secrets-manager ? 1 : 0
  path        = "/${var.cluster-name}/"
  name        = "${var.cluster-name}-SecretsManager"
  description = "The kubernetes secrets manager's required permissions"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.oidc_provider}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${local.oidc_provider}:sub": "system:serviceaccount:aws-secrets-manager:aws-secrets-manager"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "secrets-manager-assume-role-policy" {
  count = var.enable-secrets-manager ? 1 : 0
  role  = aws_iam_role.secrets-manager-role[count.index].id
  policy =<<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "sts:AssumeRole",
            "Resource": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/secrets/${var.cluster-name}/*"
        }
    ]
}
EOF
}

resource "null_resource" "secrets-manager" {
  count = var.enable-secrets-manager ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/deploy-secrets-manager.sh ${path.cwd}/output/${var.cluster-name}/kubeconfig-${var.cluster-name} ${path.module} ${data.aws_region.current.name} ${aws_iam_role.secrets-manager-role.0.arn}"
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }

  depends_on = [aws_eks_node_group.ng-workers, null_resource.kubectl]
}