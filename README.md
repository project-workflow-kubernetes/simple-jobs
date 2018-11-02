## Description:

The Swiss Data Science Center is developing a cloud-based platform for collaborative data science. The platform provides a one-stop shop to data and algorithms, enabling data scientists to easily discover and reproduce the work of their peers in a secure collaborative environment. To this end, the platform provides methods to express, share and run data science workflows contributed by the data scientists in the cloud. Workflows are currently formulated in the SDSC collaborative data science platform as Direct Acyclic Graphs (DAG) using the Common Workflow Language (CWL).

This internship is about designing a like declarative workflow language similar to GNU-make, and developing a Proof of Concept (PoC) to run the flows in a distributed application container orchestration environment such as Kubernetes.

## Goals/Benefits:

Practical experience in developing complex large scale software systems
Becoming familiar with state-of-the art application containerization and orchestration technologies such as docker and kubernetes.
Becoming familiar with cloud-based application development.
Working in an interactive and interdisciplinary research environment.

## TODOs

Project's Tasks can be found [here](https://trello.com/b/suwl3K0K/project-workflow-kubernetes).


## How to run
In order to run the task, it is needed 4 arguments:
- JOB: which is the job name
- RUN_ID: number which identifies the run (the 0 is reserved)
- CHANGED_FILE: indicates the file which was changed, it won't work if the file is not specificied in `dependencies.json`
- BUILD_IMAGE: `true` or `false` where `true` builds the image in the local machine

### Dependencies
`conda; docker; kubectl; minio; mc`

The ports 9000 (minio cluster port), 9001 (minio local port) and 80 (argo) must be free


### Run from scratch
It will install argo and minio, setup storage in the cluster and local, run the job and commit the data in the permanent storage
```bash
make run JOB=job RUN_ID=7 CHANGED_FILE=train.csv BUILD_IMAGE=false
```
After running it, the files (outputs, logs and metadata) are in the folder `s3/{JOB}/{RUN_ID}`

### Install and Uninstall Argo and Minio in the cluster
```bash
make setup-cluster JOB=job RUN_ID=7 CHANGED_FILE=train.csv BUILD_IMAGE=false
make down-cluster JOB=job RUN_ID=7 CHANGED_FILE=train.csv BUILD_IMAGE=false
```

### Get up / down a local minio (permanent) and bind minio "folders"
```bash
make setup-storage JOB=job RUN_ID=7 CHANGED_FILE=test.csv BUILD_IMAGE=false
make down-storage JOB=job RUN_ID=7 CHANGED_FILE=test.csv BUILD_IMAGE=false
```

### Run job
```bash
make run-job JOB=job RUN_ID=7 CHANGED_FILE=train.csv BUILD_IMAGE=true
make down-job JOB=job RUN_ID=7 CHANGED_FILE=train.csv BUILD_IMAGE=true
```

### Commit data to permanent storage
```bash
make commit-data JOB=job RUN_ID=7 CHANGED_FILE=train.csv BUILD_IMAGE=true
```



