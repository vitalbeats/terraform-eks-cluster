#
# Variables Configuration
#

variable "cluster-name" {
  description = "The name of the EKS cluster and resources in AWS"
  type    = string
}

variable "cluster-region" {
  description = "The AWS region to deploy the cluster into"
  type    = string
}

variable "enable-kubectl" {
  default     = true
  description = "When enabled, it will install kubectl context."
}

variable "enable-calico" {
  default     = true
  description = "When enabled, it will install Calico for network policy support."
}

variable "enable-dashboard" {
  default     = true
  description = "When enabled, it will install the Kubernetes Dashboard."
}