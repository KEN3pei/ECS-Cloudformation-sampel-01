#!/bin/sh

ACCESS_KEY=$1
SECRET_KEY=$2

ecs-cli configure profile \
    --profile-name ecs-user01 \
    --access-key ${ACCESS_KEY} \
    --secret-key ${SECRET_KEY} \

# 作成後、~/.ecs/credentialsに作成される
# 確認コマンド
# vi ~/.ecs/credentials