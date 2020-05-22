#!/bin/sh

KUBECONFIG=$1
MODULE_DIR=$2
AWS_REGION=$3
AWS_ROLE_ARN=$4

sed "s#XX-XXXX-X#${AWS_REGION}#" ${MODULE_DIR}/kubernetes-external-secrets.yaml | sed "s#AWS_ROLE_ARN#${AWS_ROLE_ARN}#" | kubectl apply -f - --kubeconfig ${KUBECONFIG}