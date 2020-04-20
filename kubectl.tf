# Set up kubectl to work properly
resource "null_resource" "output" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.cwd}/output/${var.cluster-name}"
  }
}

resource "local_file" "kubeconfig" {
  content  = local.kubeconfig
  filename = "${path.cwd}/output/${var.cluster-name}/kubeconfig-${var.cluster-name}"

  depends_on = [null_resource.output]
}

resource "local_file" "aws_auth" {
  content  = local.aws_auth
  filename = "${path.cwd}/output/${var.cluster-name}/aws-auth.yaml"

  depends_on = [
    null_resource.output,
    aws_iam_role.vb-node,
  ]
}

resource "null_resource" "kubectl" {
  count = var.enable-kubectl ? 1 : 0

  provisioner "local-exec" {
    command = <<COMMAND
      kubectl config unset users.${var.cluster-name} \
      && kubectl config unset contexts.${var.cluster-name} \
      && kubectl config unset clusters.${var.cluster-name} \
      && KUBECONFIG=~/.kube/config:./output/${var.cluster-name}/kubeconfig-${var.cluster-name} kubectl config view --flatten > ./output/${var.cluster-name}/kubeconfig_merged \
      && mv ${path.cwd}/output/${var.cluster-name}/kubeconfig_merged ~/.kube/config \
      && kubectl config use-context ${var.cluster-name}
    COMMAND
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }

  depends_on = [
    aws_eks_cluster.vb,
    null_resource.output,
  ]
}

resource "null_resource" "aws_auth" {
  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${path.cwd}/output/${var.cluster-name}/kubeconfig-${var.cluster-name} -f ${path.cwd}/output/${var.cluster-name}/aws-auth.yaml"
  }

  triggers = {
    kubeconfig_rendered = local.kubeconfig
  }

  depends_on = [
    local_file.aws_auth,
    aws_eks_cluster.vb,
  ]
}
