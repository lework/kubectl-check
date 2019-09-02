#!/bin/bash

set -e

[ -z ${KUBERNETES_USER} ] && KUBERNETES_USER="default"


if [ ! -z ${KUBERNETES_KUBECONFIG} ]; then
  [ ! -d ~/.kube ] && mkdir ~/.kube
  echo ${KUBERNETES_KUBECONFIG} | base64 -d > ~/.kube/config
  export KUBECONFIG=~/.kube/config
fi

if [[ ! -z ${KUBERNETES_TOKEN} && ! -z ${KUBERNETES_SERVER} ]]; then
  kubectl config set-credentials default --token=$(echo ${KUBERNETES_TOKEN} | base64 -d)
  if [ ! -z ${KUBERNETES_CERT} ]; then
    echo ${KUBERNETES_CERT} | base64 -d > /ca.crt
    kubectl config set-cluster default --server=${KUBERNETES_SERVER} --certificate-authority=/ca.crt
  else
    echo "WARNING: Using insecure connection to cluster"
    kubectl config set-cluster default --server=${KUBERNETES_SERVER} --insecure-skip-tls-verify=true
  fi
  kubectl config set-context default --cluster=default --user=${KUBERNETES_USER}
  kubectl config use-context default
fi

[ -f deployment.yml ] && kubectl apply -f deployment.yml --record=true
[ ! -z ${KUBERNETES_DEPLOY} ] && exec kubectl check -d ${KUBERNETES_DEPLOY}

exec "$@"
