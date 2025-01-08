apiVersion: v1
kind: Policy
metadata:
  name: enforce-specific-namespace-if-defined
spec:
  rules:
    - name: Ensure namespace is 'my-namespace' if defined
      errorMessage: "Namespace must be set to 'my-namespace' if defined."
      schemaValidation:
        - path: "metadata.namespace"
          condition: Equals
          value: "my-namespace"

datree test deployment.yaml --policy specific-namespace-policy.yaml
