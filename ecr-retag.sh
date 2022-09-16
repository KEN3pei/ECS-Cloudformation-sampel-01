#!/bin/sh

#既存のECRのlatestタグを日付タグに置き換えるスクリプト

REPOSIOTRY=$1
TAG=$2
NEW_TAG=`date '+%y%m%d%H%M%S'`

# 1. image minifestの取得コマンド作成
MANIFEST=$(aws ecr batch-get-image \
    --repository-name ${REPOSIOTRY} \
    --image-ids imageTag=${TAG} --query 'images[0].imageManifest' --output text)

# query -> 応答データのフィルタリングに使用するJMESPathクエリ。
# {
#   image: [
#      {
#           registryId: "",
#           repositoryName: "",
#           imageId: "",
#           imageManifest: {} <- こいつだけ欲しい
#       },
#   ]
# }
echo ${MANIFEST}

# 2. 新しいタグでイメージマニフェストを Amazon ECR に配置
aws ecr put-image --repository-name ${REPOSIOTRY} --image-tag ${NEW_TAG} --image-manifest "$MANIFEST"

# 3. 確認
aws ecr describe-images --repository-name ${REPOSIOTRY}