#
# Publishes a Docker image.
#
# Environment variables:
#
#   CONTAINER_REGISTRY - The hostname of your container registry.
#   REGISTRY_UN - User name for your container registry.
#   REGISTRY_PW - Password for your container registry.
#   VERSION - The version number to tag the images with.
#
# Usage:
#
#       ./scripts/cd/push-image.sh
#

set -u # or set -o nounset
: "$CONTAINER_REGISTRY"
: "$VERSION"
: "$REGISTRY_UN"
: "$REGISTRY_PW"
: "$NAME"

echo $REGISTRY_PW | aws ecr get-login-password --region us-east-1 | docker login --username $REGISTRY_UN --password-stdin $CONTAINER_REGISTRY
docker push $CONTAINER_REGISTRY/$CONTAINER_REGISTRY_NAME:$NAME
