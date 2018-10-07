# TODO: Nasty script, fix it

eval $(minikube docker-env)
docker build -f `pwd`/Dockerfile `pwd` -t job

JOB="job"
MINIO_RELEASE="RELEASE.2018-10-05T01-03-03Z"
MINIO_ACCESS_KEY="minio"
MINIO_SECRET_KEY="minio1234"
STORAGE_SIZE="5Gi"
INPUT_DATA_PATH='/data/inputs/'
OUTPUT_DATA_PATH='/data/outputs/'


kubectl create configmap ${JOB}-config  --from-literal=minio_access_key=${MINIO_ACCESS_KEY} \
        --from-literal=minio_secret_key=${MINIO_SECRET_KEY} \
        --from-literal=data_input_path=${INPUT_DATA_PATH} \
        --from-literal=data_output_path=${OUTPUT_DATA_PATH}

YAML_TEMPLATE="minio-standalone-pvc.yaml"
template=`cat "Kubernetes/${YAML_TEMPLATE}" | sed "s/{{JOB}}/${JOB}/g" | sed "s/{{STORAGE_SIZE}}/${STORAGE_SIZE}/g"`
echo "$template" | kubectl create -f -


YAML_TEMPLATE="minio-standalone-deployment.yaml"
template=`cat "Kubernetes/${YAML_TEMPLATE}" | sed "s/{{JOB}}/${JOB}/g" | sed "s/{{MINIO_RELEASE}}/${MINIO_RELEASE}/g" | sed "s/{{MINIO_ACCESS_KEY}}/${MINIO_ACCESS_KEY}/g" | sed "s/{{MINIO_SECRET_KEY}}/${MINIO_SECRET_KEY}/g"`


YAML_TEMPLATE="minio-standalone-service.yaml"
template=`cat "Kubernetes/${YAML_TEMPLATE}" | sed "s/{{JOB}}/${JOB}/g"`
echo "$template" | kubectl create -f -


YAML_TEMPLATE="minio-ingress.yaml"
template=`cat "Kubernetes/${YAML_TEMPLATE}" | sed "s/{{JOB}}/${JOB}/g"`
echo "$template" | kubectl create -f -





minikube service job-minio-service

http://192.168.99.100:31001/minio/
mc config host add s3 http://192.168.99.100:31001 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
mc mb s3/inputs/
mc mb s3/outputs/

mc cp --recursive --storage-class REDUCED_REDUNDANCY resources/*.csv s3/inputs/
mc cp --recursive --storage-class REDUCED_REDUNDANCY resources/*.pkl s3/inputs/

YAML_TEMPLATE="job-standalone-to-debug.yaml"
template=`cat "Kubernetes/${YAML_TEMPLATE}" | sed "s/{{JOB}}/${JOB}/g"`
echo "$template" | kubectl create -f -



YAML_TEMPLATE="argo-mocked-dag.yaml"
template=`cat "Kubernetes/${YAML_TEMPLATE}" | sed "s/{{JOB}}/${JOB}/g"`
echo "$template" | kubectl create -f -
