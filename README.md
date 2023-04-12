# ECS構築手順（cloudFormation x local）

### 事前準備
1. ECSを置く土台を構築
    - cloudformationでVPC -> ALB -> ECSClusterまで作成

2. ECS,ECRなどにアクセスするためのアカウントを作成
    - IAMからアクセスキーを発行
    - `./ecs-config.sh`を実行してecsにアクセスできるようにlocalにecs-profileを作成

3. ECRに上げるimageの動作確認
    - docker-compose -f docker-compose.local.yml up -d
    - `template/app:latest`イメージを生成
    - http://localhost:80 でhtmlが表示されればOK

4. awslogs-groupを先に作る
    - `template-nginx-logs`という名前で作る
    - ECSのlogを取る用のlog-groupを先に作っておく
    - docker-compose.ymlと合わせる
    - コンテナが立たないなどのエラーが出た時に原因の詳細がわかるので便利

5. ECSタスク定義用のcompose.ymlを修正する
    - docker-compose.ymlの作成
      - `image`をCloudFormationで作成したECRのARNにする
    - params.ymlの作成
      - `cp ecs-params.example.yml ecs-params.yml`
      - コメントを参考に仮置きの値を埋める

6. .envを自分の環境に合わせて埋める
    - `cp .env.sample .env`
    - コメントを参考に仮置きの値を埋める

7. サービスリンクロールを作成しておく
    - console画面から手動で一度ECSを立てれば作成され、それ以降は作らなくていいもの

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
