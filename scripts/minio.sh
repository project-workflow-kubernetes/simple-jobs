#!/usr/bin/env bash

set -eo pipefail

MINIO_RELEASE="RELEASE.2018-10-05T01-03-03Z"
MINIO_ACCESS_KEY="minio"
MINIO_SECRET_KEY="minio1234"
STORAGE_SIZE="5Gi"

declare -a templates=("minio-standalone-pvc.yaml" "minio-standalone-deployment.yaml"
                      "minio-standalone-service.yaml" "minio-ingress.yaml")

function up {
   declare -a templates=("minio-standalone-pvc.yaml" "minio-standalone-deployment.yaml"
                         "minio-standalone-service.yaml" "minio-ingress.yaml")
   for i in "${templates[@]}"
   do
       echo "$i"
       temp=`cat "Kubernetes/"$i"" \
          | sed "s/{{MINIO_RELEASE}}/${MINIO_RELEASE}/g" \
          | sed "s/{{MINIO_ACCESS_KEY}}/${MINIO_ACCESS_KEY}/g" \
          | sed "s/{{MINIO_SECRET_KEY}}/${MINIO_SECRET_KEY}/g" \
          | sed "s/{{STORAGE_SIZE}}/${STORAGE_SIZE}/g"`
       echo "$temp" | kubectl create -f -
   done

   minikube service minio-service
}


function down {
    declare -a templates=("minio-ingress.yaml"   "minio-standalone-service.yaml"
                          "minio-standalone-deployment.yaml" "minio-standalone-pvc.yaml")
    for i in "${templates[@]}"
    do
       echo "$i"
       temp=`cat "Kubernetes/"$i"" \
          | sed "s/{{MINIO_RELEASE}}/${MINIO_RELEASE}/g" \
          | sed "s/{{MINIO_ACCESS_KEY}}/${MINIO_ACCESS_KEY}/g" \
          | sed "s/{{MINIO_SECRET_KEY}}/${MINIO_SECRET_KEY}/g" \
          | sed "s/{{STORAGE_SIZE}}/${STORAGE_SIZE}/g"`
       echo "$temp" | kubectl delete -f -
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
