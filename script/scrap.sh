# stop
kubectl scale hpa <hpa-name> --replicas=0

# start
# get original min replica then patch
kubectl patch hpa <hpa-name> --type='merge' -p '{"spec":{"minReplicas": <original_value>}}'
