# RSS PACK

Sorry, this document is Japanese only

「RSS PACK」は、複数のRSSフィードを一つにまとめるサービスです。

## System dependencies

* Ruby 2.5.3
* Ruby on Rails 5.2.3
* PostgreSQL 10.4

## Setup

リポジトリをクローン後、以下を実行してください。
```
$ cd rss-pack
$ bin/setup
```
コマンドが完了するとデータベースと一緒にデモ用のデータも作られます。

以下のコマンドでサーバーを起動してください。
```
$ bin/rails s
```
サーバーが起動したらブラウザから次のURLにアクセスしてください。
* メインサイト: http://localhost:3000

デモ用のユーザーのログイン情報は以下のとおりです。
* メインサイト用ユーザー
  * メールアドレス：`test1@example.com`
  * パスワード: `password`

## How to run the test suite

テストは以下のコマンドから実行できます。
```
$ bin/rspec
```

## Deployment instructions

以下の手順でHerokuにデプロイすることができます。

次のAddonをセットアップしてください。

* [Heroku Postgres](https://devcenter.heroku.com/articles/heroku-postgresql)
  
以下の環境変数を設定してください。

| 環境変数名 | 値 |
----|----
| DATABASE_URL | <Heroku PosgresのデータベースURL> |
| TZ | Asia/Tokyo |
| RSSPACK_HOSTNAME | <Heroku上のアプリのホスト名> |

必要に応じて以下の設定が変更できます

| 環境変数名 | 値 |
----|----
| RSSPACK_FEED_FETCH_INTERVAL | <購読先からフィードを取得する間隔(秒)。未指定時：3600秒> |
| RSSPACK_PACK_RSS_CREATE_INTERVAL | <RssPackでまとめたフィードを更新する間隔(秒)。未指定時：3600秒 |

以下のコマンドを実行します。
```
$ git push heroku master
$ heroku run bin/rails db:migrate
$ heroku open
```
