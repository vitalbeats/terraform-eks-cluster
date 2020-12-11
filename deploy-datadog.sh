#!/bin/sh

KUBECONFIG=$1
CLUSTER_NAME=$2
DATADOG_API_KEY=$3
DATADOG_APP_KEY=$4
DATADOG_SITE=${5:-datadoghq.com}
MODULE_DIR=$6
DATADOG_SHARED_SECRET=$(echo -n "${CLUSTER_NAME} ${CLUSTER_NAME} ${CLUSTER_NAME}" | base64)

kubectl get customresourcedefinition.apiextensions.k8s.io/catalogsources.operators.coreos.com --kubeconfig ${KUBECONFIG} > /dev/null 2> /dev/null
if [ "$?" -ne "0" ]; then
    ${MODULE_DIR}/operator-install.sh v0.17.0 ${KUBECONFIG}
fi
kubectl apply -f https://operatorhub.io/install/datadog-operator.yaml --kubeconfig ${KUBECONFIG}
kubectl apply -f ${MODULE_DIR}/kube-state-metrics.yaml --kubeconfig ${KUBECONFIG}
kubectl apply --kubeconfig ${KUBECONFIG} -f - << EOF
apiVersion: datadoghq.com/v1alpha1
kind: DatadogAgent
metadata:
  name: datadog-agent
spec:
  credentials:
    apiKey: ${DATADOG_API_KEY}
    appKey: ${DATADOG_APP_KEY}
    token: ${DATADOG_SHARED_SECRET}
  site: ${DATADOG_SITE}
  agent:
    image:
      name: 'datadog/agent:7'
    config:
      tolerations:
        - operator: Exists
      collectEvents: true
  clusterAgent:
    image:
      name: 'datadog/cluster-agent:7'
    config:
      metricsProviderEnabled: true
      clusterChecksRunnerEnabled: true
    replicas: 2
  clusterChecksRunner:
    image:
      name: 'datadog/agent:7'
EOF
