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
