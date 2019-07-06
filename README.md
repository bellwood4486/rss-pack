# RSS PACK

RSS PACK is a service that combines your RSS feeds into one.

## System dependencies

* Ruby 2.5.3
* Ruby on Rails 5.2.3
* PostgreSQL 10.4

## Setup

After cloning this repository, run the following command:
Clone this repository, and run the following command:
```
$ cd rss-pack
$ bin/setup
```
A database is created with demo data when the command completes.

Start the server with the following command:
```
$ bin/rails s
```
Access the following URL with your browser.
* http://localhost:3000

The login information for the demo user is as follows.
* Email：`test1@example.com`
* Password: `password`

## How to run the test suite

This project uses Rspec. Run the following command:
```
$ bin/rspec
```

## Deployment instructions

Follow the steps to deploy on Heroku.

Set up the Addon.
* [Heroku Postgres](https://devcenter.heroku.com/articles/heroku-postgresql)
  
Set the following environment variables:

| Name | Value |
----|----
| DATABASE_URL | (Database URL on Heroku) |
| TZ | (Timezone of the app (ex: Asia/Tokyo)) |
| RSSPACK_HOSTNAME | (Hostname of the app on Heroku) |

You can change the following settings as need.

| Name | Value |
----|----
| RSSPACK_FEED_FETCH_INTERVAL | (Interval in seconds for fetching feeds you subscribe (Default: 3600)) |
| RSSPACK_PACK_RSS_CREATE_INTERVAL | (Interval in seconds for updating your packed feed (Default: 3600)) |

Run the following commands:
```
$ git push heroku master
$ heroku run bin/rails db:migrate
$ heroku open
```
