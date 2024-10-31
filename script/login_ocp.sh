#!/bin/bash

# Ensure required environment variables for authentication are set
if [[ -z "$OCP_USER" || -z "$OCP_PASSWORD" ]]; then
  echo "Please set the environment variables OCP_USER and OCP_PASSWORD."
  exit 1
fi

# Get the current directory name, which represents the cluster name
CLUSTER_NAME=$(basename "$PWD")

# Define cluster URLs based on folder names
declare -A CLUSTER_URLS
CLUSTER_URLS=(
  ["clusterapi"]="https://api.clusterapi.example.com:6443"
  ["clusterapi1"]="https://api.clusterapi1.example.com:6443"
  ["clusterapi2"]="https://api.clusterapi2.example.com:6443"
  # Add more clusters as needed
)

# Get the cluster URL based on the current directory name
OCP_CLUSTER_URL="${CLUSTER_URLS[$CLUSTER_NAME]}"

# Check if a valid URL was found for the current cluster
if [[ -z "$OCP_CLUSTER_URL" ]]; then
  echo "No cluster URL found for the directory '$CLUSTER_NAME'. Please add it to the script."
  exit 1
fi

# Log in to the OpenShift cluster
echo "Logging into OpenShift cluster '$CLUSTER_NAME' at $OCP_CLUSTER_URL with user $OCP_USER..."

oc login "$OCP_CLUSTER_URL" --username="$OCP_USER" --password="$OCP_PASSWORD" --insecure-skip-tls-verify=true

# Check if the login was successful
if [ $? -eq 0 ]; then
  echo "Login successful for cluster '$CLUSTER_NAME'."
else
  echo "Login failed for cluster '$CLUSTER_NAME'. Please check your credentials and cluster URL."
fi
