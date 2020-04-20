#
# Variables Configuration
#

variable "cluster-name" {
  description = "The name of the EKS cluster and resources in AWS"
  type    = string
}

variable "enable-kubectl" {
  default     = true
  description = "When enabled, it will install kubectl context into the current users kube/config."
}

variable "enable-calico" {
  default     = true
  description = "When enabled, it will install Calico for network policy support."
}

variable "enable-dashboard" {
  default     = true
  description = "When enabled, it will install the Kubernetes Dashboard."
}