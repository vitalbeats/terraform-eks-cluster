# Resources:
# * Security group for control plane (vb-cluster)
# * Security group for worker nodes (vb-nodes)
# * Ingress/Egress rules to allow the traffic suggested under 
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html

resource "aws_security_group" "vb-cluster" {
  name        = "${var.cluster-name}/ControlPlaneSecurityGroup"
  description = "Communication between control plane and nodes"
  vpc_id      = aws_vpc.vb.id
  tags = {
    Name = "${var.cluster-name}/ClusterSharedNodeSecurityGroup"
  }
}

resource "aws_security_group" "vb-nodes" {
  name        = "${var.cluster-name}/ClusterSharedNodeSecurityGroup"
  description = "Security group for all nodes in cluster"
  vpc_id      = aws_vpc.vb.id
  tags = {
    Name                                        = "${var.cluster-name}/ClusterSharedNodeSecurityGroup",
    "kubernetes.io/cluster/${var.cluster-name}" = "owned"
  }
}

# Control plane Security Rules
resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.vb-cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vb-cluster.id
  source_security_group_id = aws_security_group.vb-nodes.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

# Worker nodes Security Rules
resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.vb-nodes.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

# Inbound traffic from nodes to nodes
resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow nodes to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.vb-nodes.id
  source_security_group_id = aws_security_group.vb-nodes.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

# Inbound traffic from control plane
resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vb-nodes.id
  source_security_group_id = aws_security_group.vb-cluster.id
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vb-nodes.id
  source_security_group_id = aws_security_group.vb-cluster.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}
