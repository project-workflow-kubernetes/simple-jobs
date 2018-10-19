#!/usr/bin/env bash

MINIO_RELEASE="RELEASE.2018-10-05T01-03-03Z"
MINIO_ACCESS_KEY="minio"
MINIO_SECRET_KEY="minio1234"
STORAGE_SIZE="5Gi"


while getopts ":f:b:r:i:j:" opt; do
  case $opt in
    f) CHANGED_FILE="$OPTARG";; # file's name
    b) BUILD_DOCKERS="$OPTARG";; # `n` by default and `y` to build
    r) RUNNING_MODE="$OPTARG";; # cluster by default and `minikube` to run in minikube
    i) RUN_ID="$OPTARG";;
    j) JOB_NAME="$OPTARG";;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

JOB="${JOB_NAME}${RUN_ID}"
INPUT_DATA_PATH="/data/${JOB}/"
OUTPUT_DATA_PATH="/data/${JOB}/"
LOGS_DATA_PATH="/data/${JOB}/"
METADATA_DATA_PATH="/data/${JOB}/"


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
        kubectl create -f workflow/resources/argo-dag.yaml
        kubectl delete wf --all
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
    docker build -f `pwd`/${JOB_NAME}/Dockerfile `pwd`/${JOB_NAME} -t ${JOB_NAME}
fi


echo
echo "Registering ConfigMap in Kubernetes"
echo "---------------------------------------------------------------------------------"
kubectl create configmap ${JOB}-config  --from-literal=minio_access_key=${MINIO_ACCESS_KEY} \
        --from-literal=minio_secret_key=${MINIO_SECRET_KEY} \
        --from-literal=data_input_path=${INPUT_DATA_PATH} \
        --from-literal=data_output_path=${OUTPUT_DATA_PATH} \
        --from-literal=data_logs_path=${LOGS_DATA_PATH} \
        --from-literal=data_metadata_path=${METADATA_DATA_PATH}

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
# kubectl create ns argo
# kubectl apply -n argo -f https://raw.githubusercontent.com/argoproj/argo/v2.2.0/manifests/install.yaml
# kubectl patch svc argo-ui -n argo -p '{"spec": {"type": "LoadBalancer"}}'
# minikube service -n argo --url argo-ui

echo
echo "Waiting until Minio's endpoint is OK"
echo "---------------------------------------------------------------------------------"
# TODO: batter way to wait the endpoint
$(minikube service ${JOB}-minio-service --url)

echo
echo "Creating Buckets and Transfering required files to Minio"
echo "---------------------------------------------------------------------------------"
# mc config host add s3 s3-endpoint
mc config host add s3tmp $(minikube service ${JOB}-minio-service --url) ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
# temp; put true endpoint here
mc config host add s3 http://10.151.8.145:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY} # everyone have the same creation time...

mc mb s3tmp/${JOB}/

LAST_RUN=$(mc ls s3/${JOB_NAME}/ | awk '{print $0}' | sort -r | head -n 1 | awk '{print $5}')

while read i; do
  mc cp --recursive --storage-class REDUCED_REDUNDANCY s3/${JOB_NAME}/${LAST_RUN}/"$i" s3tmp/${JOB}/
done <workflow/resources/required_inputs.txt
# new data: mc cp --recursive --storage-class REDUCED_REDUNDANCY ${JOB_NAME}/resources/ s3tmp/${JOB}/


echo
echo
echo "Running DAG"
echo "---------------------------------------------------------------------------------"
kubectl create -f workflow/resources/argo-dag.yaml
# TODO: get the entire dag name on the fly
while [ $(argo list | grep dag-job | grep Succeeded | awk '{print $2}' | wc -l) == 0 ]
do
    sleep 1
done

echo
echo "DAG is finished, the files available in the bucket are:"
echo "---------------------------------------------------------------------------------"
mc ls s3tmp/${JOB}/
# while read i; do
#   mc cp --recursive --storage-class REDUCED_REDUNDANCY s3/${JOB_NAME}/${LAST_RUN}/"$i" s3tmp/${JOB}/
# done <s3tmp/${JOB}/metadata.txt


# while read i; do
#   mc cp --recursive --storage-class REDUCED_REDUNDANCY s3tmp/job1/* s3/job/1234/
# done <s3tmp/job1/metadata.txt


# echo
# echo "Transfering files to persistency file"
# echo "---------------------------------------------------------------------------------"
# mc mb s3/${JOB}/${RUN_ID}



echo
echo "Would you like to shutdown the infra for ${JOB}? (y/n)"
read do_shutdown
if [[ $do_shutdown = "y" ]]
then
    shutdown_infra
fi;
