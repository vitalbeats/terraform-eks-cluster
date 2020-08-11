#!/usr/bin/env bash


# This script is for installing OLM from a GitHub release

set -e

if [[ ${#@} -ne 2 ]]; then
    echo "Usage: $0 version kubecfg"
    echo "* version: the github release version"
    echo "* kubecfg: the kubeconfig to use"
    exit 1
fi

release=$1
kubecfg=$2
url=https://github.com/operator-framework/operator-lifecycle-manager/releases/download/${release}
namespace=olm

kubectl apply -f ${url}/crds.yaml --kubeconfig ${kubecfg}
kubectl apply -f ${url}/olm.yaml --kubeconfig ${kubecfg}

# wait for deployments to be ready
kubectl rollout status -w deployment/olm-operator --namespace="${namespace}"  --kubeconfig ${kubecfg}
kubectl rollout status -w deployment/catalog-operator --namespace="${namespace}"  --kubeconfig ${kubecfg}

retries=50
until [[ $retries == 0 || $new_csv_phase == "Succeeded" ]]; do
    new_csv_phase=$(kubectl get csv -n "${namespace}" --kubeconfig ${kubecfg} packageserver -o jsonpath='{.status.phase}' 2>/dev/null || echo "Waiting for CSV to appear")
    if [[ $new_csv_phase != "$csv_phase" ]]; then
        csv_phase=$new_csv_phase
        echo "Package server phase: $csv_phase"
    fi
    sleep 1
    retries=$((retries - 1))
done

if [ $retries == 0 ]; then
    echo "CSV \"packageserver\" failed to reach phase succeeded"
    exit 1
fi

kubectl rollout status -w deployment/packageserver --namespace="${namespace}" --kubeconfig ${kubecfg}