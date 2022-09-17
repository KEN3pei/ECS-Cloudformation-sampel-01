#!/bin/sh

# read .env
source ./.env

# 別名で新しいimageを生成
# docker-compose.ymlで指定している名前で生成
echo "tag: "${LOCAL_IMAGE} ${ECR_HOST}:"latest"
docker tag ${LOCAL_IMAGE} ${ECR_HOST}:"latest"

# 新しく生成したimageをecs-profileを使用してpush
ecs-cli push \
    --verbose \
    --region ${REGION} \
    --ecs-profile ${ECS_PROFILE} \
    --cluster-config ${CLUSTER_NAME} ${ECR_HOST}:"latest"

# 新しく生成したイメージを削除（不要なため）
docker rmi ${ECR_HOST}:"latest"