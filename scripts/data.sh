#!/usr/bin/env bash

set -eo pipefail


while getopts ":j:i:" opt; do
  case $opt in
    j) JOB_NAME="$OPTARG";;
    i) RUN_ID="$OPTARG";;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

MINIO_ACCESS_KEY="minio"
MINIO_SECRET_KEY="minio1234"


function up-tmp-bucket {
    valid-run-id
    mc config host add s3tmp $(minikube service minio-service --url) ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
    mc mb s3tmp/${JOB_NAME}/${RUN_ID}/
}

function down-tmp-bucket {
    mc config host remove s3tmp
}


function up-local-storage {
    IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\  -f2 | head -1)
    PORT=9000
    export MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY}
    export MINIO_SECRET_KEY=${MINIO_SECRET_KEY}
    minio server s3/ &
    echo "Warning: minio server might take some time to start locally"
    # TODO: write a better way to check if the service if already up
    sleep 20
    mc config host add s3fixed http://${IP}:${PORT} ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
}

function down-local-storage {
    mc config host remove s3fixed
    killall -9 minio # TODO: better way to do it
}

function up-storage {
    echo "not implemented"
    exit 1
}

function down-storage {
    echo "not implemented"
    exit 1
}

function valid-run-id {
    if [ $(mc ls s3fixed/${JOB_NAME}/ | awk '{print $5}' | grep ${RUN_ID} | wc -l) == 0 ];
    then
        echo "Error: run_id not valid"
        exit 1
    fi;
}

function move-to-tmp {
    LAST_RUN=$(mc ls s3/${JOB_NAME}/ | awk '{print $0}' | sort -r | head -n 1 | awk '{print $5}') # TODO: check if it is not null

    while read i;
    do
        mc cp --storage-class REDUCED_REDUNDANCY s3fixed/${JOB_NAME}/${LAST_RUN}/"$i" s3tmp/${JOB_NAME}/${RUN_ID}/"$i"
    done <workflow/resources/inputs-${JOB_NAME}-${RUN_ID}.txt

    # TODO: add step to grab the newest data available
}

function move-to-persistent {
    PERSISTENT_PATH=s3fixed/${JOB_NAME}/${RUN_ID}/
    mc mb $PERSISTENT_PATH
    mc cp --recursive --storage-class REDUCED_REDUNDANCY s3tmp/${JOB_NAME}/${RUN_ID}/ s3fixed/${JOB_NAME}/${RUN_ID}/
    echo
    echo "Info: All files of ${JOB_NAME}-${RUN_ID} are stored in ${PERSISTENT_PATH}"
}


case "${@: -1}" in
  (up-tmp-bucket)
      up-tmp-bucket
    exit 0
    ;;
  (move-to-tmp)
      move-to-tmp
    exit 0
    ;;
  (move-to-persistent)
      move-to-persistent
    exit 0
    ;;
  (up-local-storage)
      up-local-storage
    exit 0
    ;;
  (down-local-storage)
      down-local-storage
    exit 0
    ;;
  (valid-run-id)
      valid-run-id
    exit 0
    ;;
  (*)
    echo "Usage: $0 { up-tmp-bucket | move-to-tmp | down-tmp-bucket | up-local-storage | move-to-persistent | down-local-storage }"
    exit 2
    ;;
esac
