# Function to check the status of the custom resources (CR) for a given CRD in a specific namespace
check_custom_resource_status_in_namespace() {
  local crd_name=$1
  local namespace=$2

  # Check if the CRD exists
  crd_exists=$(kubectl get crd "$crd_name" 2>/dev/null)
  
  if [ -z "$crd_exists" ]; then
    echo "ERROR: CRD $crd_name does not exist."
    return 1
  fi

  # Extract the kind from the CRD name
  crd_kind=$(kubectl get crd "$crd_name" -o jsonpath='{.spec.names.kind}')

  # Get the status of all custom resources in the specified namespace related to this CRD
  resource_phases=$(kubectl get "$crd_kind" -n "$namespace" -o jsonpath='{.items[*].status.phase}' 2>/dev/null)

  # Handle error if no custom resources are found for the CRD
  if [ -z "$resource_phases" ]; then
    echo "ERROR: No custom resources found for CRD $crd_name ($crd_kind) in namespace $namespace."
    return 1
  fi

  # Split the resource phases into an array for iteration
  phases_array=($resource_phases)

  # Check if all resources are in the Running state
  all_running=true
  for phase in "${phases_array[@]}"; do
    if [ "$phase" != "Running" ]; then
      all_running=false
      break
    fi
  done

  # Provide feedback based on whether all resources are running
  if [ "$all_running" = true ]; then
    echo "All resources of CRD $crd_name ($crd_kind) in namespace $namespace are in Running state."
  else
    echo "WARNING: Some resources of CRD $crd_name ($crd_kind) in namespace $namespace are NOT in Running state."
    echo "Found statuses: ${phases_array[*]}"
  fi
}

# Function to parse the manifest and find all CRD definitions
parse_and_check_crds_in_namespace() {
  local manifest_file=$1
  local namespace=$2

  # Extract all CRD names from the manifest (matches apiVersion and kind)
  crd_names=$(yq eval -o=json "$manifest_file" | jq -r '.items[] | select(.kind == "CustomResourceDefinition") | .metadata.name')

  # Loop through each CRD and check the status of its resources in the specific namespace
  for crd_name in $crd_names; do
    echo "Checking CRD: $crd_name in namespace $namespace"
    check_custom_resource_status_in_namespace "$crd_name" "$namespace"
    if [ $? -ne 0 ]; then
      echo "ERROR: CRD $crd_name encountered an issue. Continuing to next CRD."
    fi
  done
}

# Main function to execute the script
main() {
  if [ $# -lt 2 ]; then
    echo "Usage: $0 <manifest-file> <namespace>"
    exit 1
  fi

  local manifest_file=$1
  local namespace=$2

  if [ ! -f "$manifest_file" ]; then
    echo "Error: Manifest file $manifest_file not found."
    exit 1
  fi

  # Parse and check the CRDs in the manifest file within the specified namespace
  parse_and_check_crds_in_namespace "$manifest_file" "$namespace"
}

# Run the main function
main "$@"



