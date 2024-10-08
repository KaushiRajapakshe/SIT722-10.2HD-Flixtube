# 
# Remove containers from Kubernetes.
#
# Environment variables:
#
#   NAME - The name of the microservice to delete.
#
# Usage:
#
#   ./scripts/cd/delete.sh
#

kubectl delete -f ./scripts/cd/rabbit.yaml
kubectl delete -f ./scripts/cd/mongodb.yaml
envsubst < ./scripts/cd/metadata.yaml | kubectl delete -f -
envsubst < ./scripts/cd/history.yaml | kubectl delete -f -
envsubst < ./scripts/cd/mock-storage.yaml | kubectl delete -f -
envsubst < ./scripts/cd/video-streaming.yaml | kubectl delete -f -
envsubst < ./scripts/cd/video-upload.yaml | kubectl delete -f -
envsubst < ./scripts/cd/gateway.yaml | kubectl delete -f -