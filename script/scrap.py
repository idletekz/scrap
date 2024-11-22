apiVersion: v1
kind: Secret
metadata:
  name: redis-password
type: Opaque
data:
  redis-password: xxx
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
  labels:
    app: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis
        image: redis:7.2.4
        ports:
        - containerPort: 6379
        resources:
          limits:
            memory: "256Mi"
            cpu: "500m"
          requests:
            memory: "128Mi"
            cpu: "250m"
        env:
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: redis-password
              key: redis-password
        command: ["redis-server"]
        args:
        - "--requirepass"
        - "$(REDIS_PASSWORD)"
        - "--maxmemory"
        - "2gb"
        - "--maxmemory-policy"
        - "allkeys-lru"
---

apiVersion: v1
kind: Service
metadata:
  name: redis-service
spec:
  selector:
    app: redis
  ports:
  - protocol: TCP
    port: 6379
    targetPort: 6379
  type: clusterIP

