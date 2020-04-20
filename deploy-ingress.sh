#!/bin/sh

KUBECONFIG=$1
ACM_ARN=$2

if [ "${ACM_ARN}x" == "x" ]; then
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/aws/deploy.yaml --kubeconfig ${KUBECONFIG}
else
    curl https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/aws/deploy-tls-termination.yaml | sed "s#XXX.XXX.XXX/XX#'10.0.0.0/16'#" | sed "s#arn:aws:acm:us-west-2:XXXXXXXX:certificate/XXXXXX-XXXXXXX-XXXXXXX-XXXXXXXX#${ACM_ARN}#" | kubectl apply -f - --kubeconfig ${KUBECONFIG}
fi