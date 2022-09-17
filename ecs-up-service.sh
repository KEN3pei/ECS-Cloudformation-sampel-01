#!/bin/sh

# read .env
source ./.env

# FILE="./docker-compose.yml"
# PARAMS_FILE="./ecs-params.yml"
# NAME="nginx"
# NAME="allhome-project"
# TASK_EXEC_IAM_ROLE_ARN="arn:aws:iam::706353777632:role/allhome-ecs-cluster-ECSTaskExecutionRolePolicy"
# INSTANCE_ROLE_ARN="arn:aws:iam::706353777632:role/allhome-ecs-cluster-instance-role"
# REGION="ap-northeast-1"
# CLUSTER_NAME="allhome-ecs-cluster"
# service
# TARGET_GROUP_ARN="arn:aws:elasticloadbalancing:ap-northeast-1:706353777632:targetgroup/allhome-ecs-cluster-tg/a2d1231b3a43f180"
# CONTAINER_NAME="nginx"
# CONTAINER_NAME="front"
# CONTAINER_PORT="80"
# ECS_PROFILE="ecs-user01"
# LAUNCH_TYPE="FARGATE"
# TIMEOUT="6.5"

# ecs-cli compose 
    # タスク用の IAM ロール
    # --task-role-arn ${IAM_ROLE_ARN} \ --roleと同じ？
# service create
    # service rinked role デフォルトでは作成済みのroleが使用されるはず
    # https://www.yokoyan.net/entry/2021/10/15/180000
    # --role ${IAM_ROLE_ARN} \

ecs-cli compose \
    --verbose \
    --file ${FILE} \
    --project-name ${NAME} \
    --task-role-arn ${TASK_EXEC_IAM_ROLE_ARN} \
    --ecs-params ${PARAMS_FILE} \
    --region ${REGION} \
    --cluster ${CLUSTER_NAME} \
service up \
    --deployment-max-percent 200 \
    --deployment-min-healthy-percent 100 \
    --target-groups \
    targetGroupArn=${TARGET_GROUP_ARN},containerName=${CONTAINER_NAME},containerPort=${CONTAINER_PORT} \
    --role ${INSTANCE_ROLE_ARN} \
    --launch-type ${LAUNCH_TYPE} \
    --ecs-profile ${ECS_PROFILE} \
    --cluster ${CLUSTER_NAME} \