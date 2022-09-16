#!/bin/sh

# Defaults
REGION="ap-northeast-1"
ECS_PROFILE="ecs-user01"
CLUSTER_NAME="allhome-ecs-cluster"
ECR_HOST="706353777632.dkr.ecr.ap-northeast-1.amazonaws.com/allhome/app"

# IMAGE
    echo "IMAGEを入力してください(default: allhome/app)"
    read image
    IMAGE=${image:="allhome/app"}
# TAG
    echo "IMAGEのTAGを入力してください(default: latest)"
    read tag
    TAG=${tag:="latest"}

# 別名で新しいimageを生成
echo "tag: "${ECR_HOST}:${VERSION}
docker tag ${IMAGE}:${TAG} ${ECR_HOST}:"latest"

# 新しく生成したimageをecs-profileを使用してpush
ecs-cli push \
    --verbose \
    --region ${REGION} \
    --ecs-profile ${ECS_PROFILE} \
    --cluster-config ${CLUSTER_NAME} ${ECR_HOST}:"latest"

# 新しく生成したイメージを削除（不要なため）
docker rmi ${ECR_HOST}:"latest"