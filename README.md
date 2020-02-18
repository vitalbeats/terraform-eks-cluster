# EKS Getting Started Guide Configuration

This is the full configuration from https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html

See that guide for additional information.

NOTE: This full configuration utilizes the [Terraform http provider](https://www.terraform.io/docs/providers/http/index.html) to call out to icanhazip.com to determine your local workstation external IP for easily configuring EC2 Security Group access to the Kubernetes master servers. Feel free to replace this as necessary.

# TODO

- EC2 SSH access (aws_eks_node_group can set remote_access.ec2_ssh_key_name), to be able to access the kubelets themselves.
- CloudWatch or other log aggregation.
- Amazon EBS + relevant storage driver and sane defaults.
