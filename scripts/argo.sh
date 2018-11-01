#!/usr/bin/env bash

set -eo pipefail


function up {
    kubectl create ns argo
    kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/v2.2.0/manifests/install.yaml
    kubectl patch svc argo-ui -n argo -p '{"spec": {"type": "LoadBalancer"}}'
}

function down {
    kubectl delete ns argo

    while [ $(kubectl get ns | grep argo | wc -l) != 0 ];
    do
        sleep 1
    done
}


case "$1" in
  (up)
    up
    exit 0
    ;;
  (down)
      down
    exit 0
    ;;
  (*)
    echo "Usage: $0 { up | down }"
    exit 2
    ;;
esac
