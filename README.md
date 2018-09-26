## Description:

The Swiss Data Science Center is developing a cloud-based platform for collaborative data science. The platform provides a one-stop shop to data and algorithms, enabling data scientists to easily discover and reproduce the work of their peers in a secure collaborative environment. To this end, the platform provides methods to express, share and run data science workflows contributed by the data scientists in the cloud. Workflows are currently formulated in the SDSC collaborative data science platform as Direct Acyclic Graphs (DAG) using the Common Workflow Language (CWL).

This internship is about designing a like declarative workflow language similar to GNU-make, and developing a Proof of Concept (PoC) to run the flows in a distributed application container orchestration environment such as Kubernetes.

## Goals/Benefits:

Practical experience in developing complex large scale software systems
Becoming familiar with state-of-the art application containerization and orchestration technologies such as docker and kubernetes.
Becoming familiar with cloud-based application development.
Working in an interactive and interdisciplinary research environment.

## First TODOs

- Setup a project (simple example, preprocessing, test/train split, train the model, score the model) that runs with makefile / pydoit 
- Get the DAG file from that 
- Generate yamls file based on this DAG (adapt this yaml to be maybe able to run with argo)
- Write a function to generate yaml files starting from an arbitrary point
- Store the data of hashes inside the graphs
- Write a function to get the right point in the graph
   -- data update: check if data actually changed and start the dag from the task that depends on this data
   -- code update: check if the code change actually change the output and start the dag from this point

