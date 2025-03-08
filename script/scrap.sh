apiVersion: v1
kind: ConfigMap
metadata:
  name: startup-script
data:
  entrypoint.sh: |
    #!/bin/sh
    set -e
    echo "Copying executable to writable location..."
    cp /app/my-executable /writable/my-executable
    chmod +x /writable/my-executable
    echo "Running the executable..."
    exec /writable/my-executable
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
    - name: my-container
      image: my-image
      command: ["/bin/sh", "/scripts/entrypoint.sh"]
      volumeMounts:
        - name: scripts
          mountPath: /scripts
        - name: writable
          mountPath: /writable
  volumes:
    - name: scripts
      configMap:
        name: startup-script
        defaultMode: 0755
    - name: writable
      emptyDir: {}
