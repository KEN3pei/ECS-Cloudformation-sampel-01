#!/bin/sh

# read .env
source ./.env

# ecs-cli compose 
    # タスク用の IAM ロール
    # --task-role-arn ${IAM_ROLE_ARN} \ --roleと同じ？
# service create
    # service rinked role デフォルトでは作成済みのroleが使用されるはず
    # https://www.yokoyan.net/entry/2021/10/15/180000
    # --role ${INSTANCE_ROLE_ARN} \

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
    --launch-type ${LAUNCH_TYPE} \
    --ecs-profile ${ECS_PROFILE} \
    --cluster ${CLUSTER_NAME} \