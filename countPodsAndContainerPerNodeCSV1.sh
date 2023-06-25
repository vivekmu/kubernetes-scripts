#!/bin/bash

# Count number of pods and containers per node in a kubernetes cluster and write a CSV formatted output

errorExit () {
    echo -e "\nERROR: $1\n"
    exit 1
}

# Test connection to cluster
kubectl cluster-info > /dev/null || errorExit "Connection to cluster failed"

# Get the list of nodes in the cluster
nodes=$(kubectl get nodes -o jsonpath="{.items[*].metadata.name}")

# Header for CSV
echo "Node,Pods count,Containers count"

# Loop over the nodes
for node in ${nodes}; do
    # Get the list of pods running on the current node
    pods=$(kubectl get pods -A -o jsonpath="{.items[*].metadata.name}" --field-selector spec.nodeName="${node}")
    #kubectl get pod -o json | jq -r '["Name","Status","Containers","ReadyContainers"],(.items[] | [.metadata.name, .status.phase, (.spec.containers | length), (.status.containerStatuses[] | select(.ready==true) | [values] | length)]) --field-selector spec.nodeName="${node}" | @csv' > test1.csv
    
    # Get the list of containers running on the current node
    containers=$(kubectl get pods -A -o jsonpath="{.items[*].spec.containers[*].name}" --field-selector spec.nodeName="${node}")

    echo -e "Node,Pods count,Containers count,\n$(echo "${node}" | wc -w | tr -d ' '),$(echo "${pods}" | wc -w | tr -d ' '),$(echo "${containers}" | wc -w | tr -d ' ')"  >  test1.csv
done
