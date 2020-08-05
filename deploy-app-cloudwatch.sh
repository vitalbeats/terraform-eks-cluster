#!/bin/sh

KUBECONFIG=$1
CLUSTER_NAME=$2
CLUSTER_REGION=$3

kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml --kubeconfig ${KUBECONFIG}
kubectl create configmap cluster-info --from-literal=cluster.name=${CLUSTER_NAME} --from-literal=logs.region=${CLUSTER_REGION} -n amazon-cloudwatch --kubeconfig ${KUBECONFIG}
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluentd/fluentd.yaml