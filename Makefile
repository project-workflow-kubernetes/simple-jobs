JOB=job
RUN_ID=4
CHANGED_FILE=train.csv

help:
	@echo "- setup-cluster: start minikube, install argo and minio in the cluster"
	@echo "- setup-storage: setup temporary bucket in the cluster and persistent storage in local machine"
	@echo "- run-job: submit dag to run in the cluster"
	@echo "- commit-data: moves data from temporary bucket to persistent storage"
	@echo "- run: setup-cluster | setup-storage | run-job | commit-data"
	@echo "- down-job: kills pods related with dag"
	@echo "- down-storage: kills minio process in local machine and deletes bucket in the cluster"
	@echo "- down-cluster: kills argo and minio and stops minikube"


setup-cluster:
	@minikube start
	-@bash scripts/argo.sh up
	-@bash scripts/minio.sh up


setup-storage:
	@bash scripts/data.sh -i ${RUN_ID} -j ${JOB} up-local-storage
	@bash scripts/data.sh -i ${RUN_ID} -j ${JOB} valid-run-id
	@bash scripts/data.sh -i ${RUN_ID} -j ${JOB} up-tmp-bucket
	@bash scripts/job.sh -i ${RUN_ID} -j ${JOB} -f ${CHANGED_FILE} generate-dag
	@bash scripts/data.sh -i ${RUN_ID} -j ${JOB} move-to-tmp


run-job:
	@bash scripts/job.sh -i ${RUN_ID} -j ${JOB} run


commit-data:
	@bash scripts/data.sh -i ${RUN_ID} -j ${JOB} move-to-persistent


run: setup-cluster setup-storage run-job commit-data


down-job:
	@bash scripts/job.sh -i ${RUN_ID} -j ${JOB} down
	@bash scripts/data.sh down-tmp-bucket
	@bash scripts/data.sh down-local-storage


down-storage:
	@bash scripts/data.sh down-tmp-bucket
	@bash scripts/data.sh down-local-storage


down-cluster:
	-@bash scripts/argo.sh down
	-@bash scripts/minio.sh down
	@minikube stop
