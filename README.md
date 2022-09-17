# ECS構築手順（cloudFormation x local）

### 事前準備
1. cloudformationでVPC -> ALB -> ECSClusterまで作成

2. ecs profileを設定
  - アクセスキーを発行
  - `./ecs-config.sh`を実行してecsにアクセスできるようにprofileを作成

3. imageの動作確認
  - docker-compose -f docker-compose.local.yml up -d
  - `allhome/app:latest`イメージを生成
  - http://localhost:80 でhtmlが表示されればOK

4. awslogs-groupは先に作る
  - `template-nginx-logs`
  - ECSのlogを取る用のlog-groupを先に作っておく
  - docker-compose.ymlと合わせる

5. compose.ymlの設定を埋める
  - docker-compose.ymlのimage部分を自分の環境に合わせる
  - params.example.ymlを参考にparams.ymlを作る

6. .envを自分の環境に合わせて埋める

7. サービスリンクロールを作成しておく

### 構築開始

1. イメージをECRにpush(latest tagでpush)
  - `./ecs-push.sh`を実行（可変部分は引数で受け取るようにする）
  - latest, 日付のイメージが最新にあり、その状態でlatestタグのイメージをpushするとlatestタグが最新の方に勝手に付け変わる。

2. pushしたイメージに日付tagを追加
  - `./ecr-retag.sh template/app latest`
  - ここで日付タグをつけておくことで最新のlatestタグがpushされてもイメージが日付だけになって残る。
    タグの運用イメージ
    ```
    1. ローカルのイメージ更新
    2. イメージをlatestでpush
    3. 古いlatestタグが最新のイメージに付け変わる
    4. latestイメージに日付タグも追加
    ```

3. ecs-cli compose service upでサービスのタスク定義を作成・デプロイ
  - `./ecs-up-service.sh`を実行
  - ECSのタスク定義一覧から確認可能

4. あらかじめ用意しているALBのDNS名でアクセス
   
   - localで試した時と同じhtmlが表示されれば成功！
