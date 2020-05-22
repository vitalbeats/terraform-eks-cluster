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

variable "enable-ingress" {
  default     = true
  description = "When enabled, it will deploy an Ingress controller."
}

variable "ingress-acm-arn" {
  default     = ""
  description = "When a non-empty value, it will enable TLS Ingresses backed by an ACM certificate."
}

variable "enable-secrets-manager" {
  default     = true
  description = "When enabled, it will deploy an ExternalSecrets manager linking to AWS Secrets Manager."
}