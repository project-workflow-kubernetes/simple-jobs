#!/usr/bin/env bash

set -eo pipefail

while getopts ":f:j:i:" opt; do
  case $opt in
    f) CHANGED_FILE="$OPTARG";; # file's name
    j) JOB_NAME="$OPTARG";;
    i) RUN_ID="$OPTARG";;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

INPUT_DATA_PATH="/data/${JOB_NAME}/${RUN_ID}/"
OUTPUT_DATA_PATH="/data/${JOB_NAME}/${RUN_ID}/"
LOGS_DATA_PATH="/data/${JOB_NAME}/${RUN_ID}/"
METADATA_DATA_PATH="/data/${JOB_NAME}/${RUN_ID}/"


function build-local-image {
    eval $(minikube docker-env)
    docker build -f `pwd`/${JOB_NAME}/Dockerfile `pwd`/${JOB_NAME} -t ${JOB_NAME}
}

function build-and-push-image {
    export REPO=liabifano
    docker login --username=${DOCKER_USER} --password=${DOCKER_PASS} 2> /dev/null
    docker build -f `pwd`/${JOB_NAME}/Dockerfile `pwd`/${JOB_NAME} -t ${REPO}/${JOB_NAME}
    docker push ${REPO}/${JOB_NAME}
}

function generate-dag {
    source activate workflow
    python workflow/src/workflow/main.py ${JOB_NAME} ${CHANGED_FILE} ${RUN_ID}
    source deactivate
}

function run {
    kubectl create configmap ${JOB_NAME}-${RUN_ID}-config  \
        --from-literal=data_input_path=${INPUT_DATA_PATH} \
        --from-literal=data_output_path=${OUTPUT_DATA_PATH} \
        --from-literal=data_logs_path=${LOGS_DATA_PATH} \
        --from-literal=data_metadata_path=${METADATA_DATA_PATH}

    kubectl create -f workflow/resources/dag-${JOB_NAME}-${RUN_ID}.yaml
}


function down {
    kubectl delete configmap ${JOB_NAME}-${RUN_ID}-config

    kubectl get wf | grep dag-${JOB_NAME} | awk '{print $1}' | \
        while read i; do
            kubectl delete wf "$i"
        done
}



case "${@: -1}" in
  (build-local-image)
      build-local-image
    exit 0
    ;;
  (build-and-push-image)
      build-and-push-image
    exit 0
    ;;
  (generate-dag)
      generate-dag
    exit 0
    ;;
  (run)
      run
    exit 0
    ;;
  (down)
      down
    exit 0
    ;;
  (*)
    echo "Usage: $0 {build-local-image|build-and-push-image|generate-dag|run|down}"
    exit 2
    ;;
esac
