apiVersion: v1
kind: Policy
metadata:
  name: enforce-specific-namespace-if-defined
spec:
  rules:
    - name: Namespace must be defined
      errorMessage: "Namespace must be defined and set to 'my-namespace'."
      schemaValidation:
        - path: "metadata.namespace"
          condition: Exists

    - name: Ensure namespace is 'my-namespace'
      errorMessage: "Namespace must be set to 'my-namespace'."
      schemaValidation:
        - path: "metadata.namespace"
          condition: Equals
          value: "my-namespace"

datree test deployment.yaml --policy specific-namespace-policy.yaml
