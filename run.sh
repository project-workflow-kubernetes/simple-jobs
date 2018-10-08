#!/usr/bin/env bash

JOB="job"
MINIO_RELEASE="RELEASE.2018-10-05T01-03-03Z"
MINIO_ACCESS_KEY="minio"
MINIO_SECRET_KEY="minio1234"
STORAGE_SIZE="5Gi"
INPUT_DATA_PATH='/data/inputs/'
OUTPUT_DATA_PATH='/data/outputs/'


while getopts ":f:b:r:" opt; do
  case $opt in
    f) CHANGED_FILE="$OPTARG";; # file's name
    b) BUILD_DOCKERS="$OPTARG";; # `n` by default and `y` to build
    r) RUNNING_MODE=="$OPTARG";; # cluster by default and `minikube` to run in minikube
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done


function shutdown_infra {
    if ! [[ -z $(kubectl get services | grep job-minio-service) ]];
    then
        declare -a templates=("minio-standalone-pvc.yaml" "minio-standalone-deployment.yaml"
                              "minio-standalone-service.yaml" "minio-ingress.yaml")
        for i in "${templates[@]}"
        do
            echo "$i"
            temp=`cat "Kubernetes/"$i"" \
                  | sed "s/{{JOB}}/${JOB}/g" \
                  | sed "s/{{MINIO_RELEASE}}/${MINIO_RELEASE}/g" \
                  | sed "s/{{MINIO_ACCESS_KEY}}/${MINIO_ACCESS_KEY}/g" \
                  | sed "s/{{MINIO_SECRET_KEY}}/${MINIO_SECRET_KEY}/g" \
                  | sed "s/{{STORAGE_SIZE}}/${STORAGE_SIZE}/g"`
            echo "$temp" | kubectl delete -f -
        done
    fi;

    if ! [[ -z $(kubectl get configmap | grep ${JOB}-config) ]];
    then
        kubectl delete configmap ${JOB}-config
    fi;

    if ! [[ -z $(kubectl get wf | grep ${JOB}) ]];
    then
        echo "TODO"
    fi;
}

shutdown_infra

echo
echo "Generating DAG file"
echo "---------------------------------------------------------------------------------"
source activate workflow
python workflow/src/workflow/main.py ${JOB} ${CHANGED_FILE}
source deactivate


if [[ $RUNNING_MODE == "minikube" ]]
then
    eval $(minikube docker-env)
fi
if [[ $BUILD_DOCKERS == "y" ]]
then
    echo
    echo "Building Docker Images"
    echo "---------------------------------------------------------------------------------"
    docker build -f `pwd`/${JOB}/Dockerfile `pwd`/${JOB} -t ${JOB}
fi


echo
echo "Registering ConfigMap in Kubernetes"
echo "---------------------------------------------------------------------------------"
kubectl create configmap ${JOB}-config  --from-literal=minio_access_key=${MINIO_ACCESS_KEY} \
        --from-literal=minio_secret_key=${MINIO_SECRET_KEY} \
        --from-literal=data_input_path=${INPUT_DATA_PATH} \
        --from-literal=data_output_path=${OUTPUT_DATA_PATH}

echo
echo "Deploying Minio in a PVC in Kubernetes"
echo "---------------------------------------------------------------------------------"
declare -a templates=("minio-standalone-pvc.yaml" "minio-standalone-deployment.yaml"
                     "minio-standalone-service.yaml" "minio-ingress.yaml")
for i in "${templates[@]}"
do
    echo "$i"
    temp=`cat "Kubernetes/"$i"" \
          | sed "s/{{JOB}}/${JOB}/g" \
          | sed "s/{{MINIO_RELEASE}}/${MINIO_RELEASE}/g" \
          | sed "s/{{MINIO_ACCESS_KEY}}/${MINIO_ACCESS_KEY}/g" \
          | sed "s/{{MINIO_SECRET_KEY}}/${MINIO_SECRET_KEY}/g" \
          | sed "s/{{STORAGE_SIZE}}/${STORAGE_SIZE}/g"`
    echo "$temp" | kubectl create -f -
done

echo
echo "Deploying Argo in Kubernetes"
echo "---------------------------------------------------------------------------------"
# TODO


echo
echo "Waiting until Minio's endpoint is OK"
echo "---------------------------------------------------------------------------------"
# TODO: batter way to wait the endpoint
$(minikube service job-minio-service --url)

echo
echo "Creating Buckets and Transfering required files to Minio"
echo "---------------------------------------------------------------------------------"
mc config host add s3 $(minikube service job-minio-service --url) ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
mc mb s3/inputs/
mc mb s3/outputs/

mc cp --recursive --storage-class REDUCED_REDUNDANCY ${JOB}/resources/*.csv s3/inputs/
mc cp --recursive --storage-class REDUCED_REDUNDANCY ${JOB}/resources/*.pkl s3/inputs/

echo
echo "Running DAG"
echo "---------------------------------------------------------------------------------"
# # YAML_TEMPLATE="argo-mocked-dag.yaml"
# # template=`cat "Kubernetes/${YAML_TEMPLATE}" | sed "s/{{JOB}}/${JOB}/g"`
# # echo "$template" | kubectl create -f -


echo
echo "DAG is finished, the files available are:"
echo "---------------------------------------------------------------------------------"

echo
echo "Would you like to shutdown the infra for ${JOB}? (y/n)"
read do_shutdown
if [ $do_shutdown = "y" ]
then
    shutdown_infra
fi
