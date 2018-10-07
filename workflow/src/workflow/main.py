import os
import json
import numpy as np

import argparse
import networkx as nx


DEPENDENCIES_FILE = os.path.join(os.path.abspath(
    os.path.join(__file__, '../../../..')), 'dependencies.json')
RESOURCES_PATH =  os.path.join(os.path.abspath(
    os.path.join(__file__, '../../../')), 'resources')


def get_all_files(dependencies):
    all_scripts = list(dependencies.keys())
    all_inputs = [n for m in [x['inputs']
                              for x in dependencies.values()] for n in m]
    all_outputs = [n for m in [x['outputs']
                               for x in dependencies.values()] for n in m]
    return list(set(all_scripts + all_outputs + all_inputs))


def build_DAG(tasks):
    edges = []
    attrs = {}

    for t in tasks:
        task = tasks[t]
        edges += [(input_, t) for input_ in task['inputs']]
        edges += [(t, output_) for output_ in task['outputs']]

        attrs[t] = {'type': 'operator'}
        attrs.update(dict([[x, {'type': 'data'}]
                           for x in task['inputs'] + task['outputs']]))

    return edges, attrs


def is_DAG_valid(dag):
    # TODO: add more test such as no missing nodes and no nodes alone
    return nx.is_directed_acyclic_graph(dag)


def create_subgraph(G, node):
    edges = nx.dfs_successors(G, node)
    nodes = []

    for k, v in edges.items():
        nodes.extend([k])
        nodes.extend(v)

    return G.subgraph(nodes)


def next_tasks(dag, changed_step):
    sub_dag = create_subgraph(dag, changed_step)

    sorted_sub_dag = nx.lexicographical_topological_sort(sub_dag)
    data_sub_dag = sub_dag.nodes(data=True)

    pendent_tasks = [node for node in sorted_sub_dag
                     if data_sub_dag[node]['type'] == 'operator']

    return pendent_tasks


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("changed_file", help="changed file", type=str)
    parser.add_argument("job_name", help="job_name", type=str)
    args = parser.parse_args()
    changed_file = args.changed_file
    job_name = args.job_name

    dependencies = json.load(open(DEPENDENCIES_FILE))

    if changed_file not in get_all_files(dependencies):
        raise KeyError('{file} is not a valid file in this job'
                       .format(file=changed_file))

    edges, nodes_attr = build_DAG(dependencies)
    dag = nx.DiGraph(edges)
    nx.set_node_attributes(dag, nodes_attr)

    if not is_DAG_valid(dag):
        raise Exception('Not valid DAG, check your dependencies.json file')

    next_tasks = next_tasks(dag, changed_file)
    requeried_inputs = dependencies[changed_file]['inputs']

    print(next_tasks)
    print(requeried_inputs)
    print(RESOURCES_PATH)
