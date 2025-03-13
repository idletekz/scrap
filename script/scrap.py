yq eval -o=json '[. | select(.kind == "Deployment") | {Deployment: .metadata.name, Replicas: .spec.replicas}]' manifest.yaml
