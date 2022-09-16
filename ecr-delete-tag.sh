#!/bin/sh

REPOSIOTRY=$1
TAG=$2

# delete tag
aws ecr batch-delete-image \
     --repository-name ${REPOSIOTRY} \
     --image-ids imageTag=${TAG}

# result log
aws ecr list-images \
     --repository-name ${REPOSIOTRY}