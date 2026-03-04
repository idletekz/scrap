volumes:
- name: shared
  emptyDir: {}

initContainers:
- name: detect-service-color
  image: registry.k8s.io/kubectl:v1.30.0
  command:
  - sh
  - -c
  - |
    COLOR=$(kubectl get svc my-service -o jsonpath='{.spec.selector.color}')
    echo $COLOR > /shared/color
  volumeMounts:
  - name: shared
    mountPath: /shared

containers:
- name: app
  image: myapp
  command:
  - sh
  - -c
  - |
    export SERVICE_COLOR=$(cat /shared/color)
    exec /start-app.sh
  volumeMounts:
  - name: shared
    mountPath: /shared
