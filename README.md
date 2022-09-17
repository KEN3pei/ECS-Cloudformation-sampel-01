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

### 構築開始

1. イメージをECRにpush(latest tagでpush)
  - `./ecs-push.sh`を実行（可変部分は引数で受け取るようにする）
  - latest, 日付のイメージが最新にあり、その状態でlatestタグのイメージをpushするとlatestタグが最新の方に勝手に付け変わる。

2. pushしたイメージに日付tagを追加
  - `./ecr-retag.sh template/app latest`
  - ここで日付タグをつけておくことで最新のlatestタグがpushされてもイメージが日付だけになって残る。
    ```
    1. ローカルのイメージ更新
    2. イメージをlatestでpush
    3. 古いlatestタグが最新のイメージに付け変わる
    4. latestイメージに日付タグも追加
    ```

3. ecs-cli compose service upでサービスのタスク定義を作成・デプロイ（Activate -> Running）
  - `./ecs-up-service.sh`を実行
  - ECSのタスク定義一覧から確認可能
  - 以下のようなエラーが出た
    ```shell
    FATA[0303] Deployment has not completed: Running count has not changed for 5.00 minutes 
    ```
    どうやらRoll関連のエラーらしい  
    ```shell
    service nginx failed to launch a task with (error ECS was unable to assume the role 'arn:aws:iam::706353777632:role/allhome-ecs-cluster-instance-role' that was provided for this task. Please verify that the role being passed has the proper trust relationship and permissions and that your IAM user has permissions to pass this role.).
    ```
    - 公式のトラブルシューティングを試す[公式]（https://aws.amazon.com/jp/premiumsupport/knowledge-center/ecs-unable-to-assume-role/）
      `aws iam get-role --role-name allhome-ecs-cluster-instance-role`
      どうやら2つめの信頼関係ポリシーに`ecs-tasks.amazonaws.com`が許可されていない。
  - 別のエラーが出た
    ```shell
    CannotPullContainerError: inspect image has been retried 5 time(s): failed to resolve ref "docker.io/allhome/app:latest": failed to do request: Head https://registry-1.docker.io/v2/allhome/app/manifests/latest: dial tcp 54.83.42.45:443: i/o timeout
    ```
  - [公式](https://aws.amazon.com/jp/premiumsupport/knowledge-center/ecs-pull-container-error/)のトラブルシューティング
    - ~~おそらくECR読み取りの権限がない~~(管理者権限のIAMで実行しているので関係なさそう)
    - ~~自動割り当てパブリックIPがなさそう~~
    - A. imageの指定するECRイメージのURlが間違っていた（/allhome/app -> 706353777632.dkr.ecr.ap-northeast-1.amazonaws.com/allhome/app:latest）
  - 別のエラー
    ```
    ResourceInitializationError: unable to pull secrets or registry auth: execution resource retrieval failed: unable to retrieve ecr registry auth: service call has been retried 3 time(s): RequestError: send request failed caused by: Post https://api.ecr.ap-northeast-1.amazonaws.com/: dial tcp 52.119.222.141:443: i/o timeout
    ```
  - private subnetからALB経由でECRを見に行くことはできないらしい（igwをつけるかVPCエンドポイントをつける必要がある）
  - 別のエラー...
   `Essential container ~`
   - とりあえずCloudWatchLogsを動かせるようにして動作確認
    - `standard_init_linux.go:228: exec user process caused: exec format error`
    - どうやらCPUアーキテクチャの違いによるイメージの問題らしい。
      - nginx -> amd64/nginxにイメージを変更
  - 新しくテンプレ作成時に出たエラー
    ```shell
    ERRO[0005] Error creating service                        error="InvalidParameterException: You cannot specify an IAM role for services that require a service linked role.
    ```
    - 公式より
    - awsvpcネットワーク モードを使用する場合、サービスにリンクされたロールが必要です
    - アカウントが Amazon ECS サービスにリンクされたロールをすでに作成している場合、ここでロールを指定しない限り、そのロールがサービスに使用される。
    - 解決策（https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/using-service-linked-roles.html）
    - サービスリンクRoleが手動でECSを作成した時かどこかのタイミングで作られてしまっていた。
    - そうなるとECSのインスタンスロールはサービスリンクロールで固定されるので、ecs-cliでservice upするときにエラーが出てしまっていた。
    - サービス起動時にインスタンスロールの指定をなくすことで解決
    - TODO: テンプレ作成時は事前にサービスリンクロールを作るように指示を追加する
    - TODO: インスタンスロールの作成をテンプレから外す

    - awslogs-groupは先に作るようにする
    - params.ymlに.envは反映できない（パラメータストアとか使うしかない）


4. ecs service経由でECR上のイメージをpullしてきたのち、task実行

5. あらかじめ用意しているALBのDNS名でアクセス
   
   - localで試した時と同じhtmlが表示されれば成功！
   - 
