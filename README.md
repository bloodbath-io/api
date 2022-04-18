# Install

```
mix deps.get
mix ecto.setup
```

# Start

## Standard

```
mix phx.server
```

## Docker

```
docker-compose build
docker-compose up
```

## With REPL (IEx)
This is the equivalent of binding.pry
If you want to use it inside the code
You need to start the server this way

```
iex -S mix phx.server
```

# Production

## Create everything to production

### Have a configuration ready

It should look like that

```
DATABASE_URL:             postgresql://postgres:e95e770ead483835dfa738b086074b21@bloodbath.ce1deu8qn9z0.eu-west-1.rds.amazonaws.com:5432/bloodbath
DOKKU_APP_RESTORE:        1
DOKKU_APP_TYPE:           herokuish
DOKKU_LETSENCRYPT_EMAIL:  laurent@bloodbath.io
DOKKU_PROXY_PORT:         80
DOKKU_PROXY_PORT_MAP:     http:80:5000 https:443:5000
DOKKU_PROXY_SSL_PORT:     443
GIT_REV:                  ab5e7dd366339be0e84afeec61678c1c0f02a371
MIX_ENV:                  prod
SECRET_KEY_BASE:          UN5XrhCoYiMM/ALWhnUDgCvEOjAUI8vaZAKSu0Mq0mTDdfkJspaXj7uzqXeuuYQ
```

## Dokku essentials

```
dokku postgres:expose bloodbath # expose database port to access it from any computer
```

## Deploy in production

```
git push dokku
```

## Logs

- We use Papertrailapp to monitor - the free tier - https://papertrailapp.com/dashboard
- Please use laurent@bloodbath.io to access it for now

## SQL checks

```
SELECT * FROM pg_stat_activity WHERE datname = 'bloodbath'

select pg_terminate_backend(pid)
from pg_stat_activity
where state != 'active'

alter system set idle_session_timeout='5min';


SELECT * FROM events_responses WHERE type = 'ok'
SELECT * FROM events WHERE response_received_at IS NOT NULL

SELECT scheduled_for, dispatched_at, response_received_at, dispatched_at - scheduled_for AS dispatch_time, response_received_at - scheduled_for AS response_time FROM events

```

## Short guide to AWS

- We currently don't use ECS because it's useless
- We use a public EC2 instance and RDS connected to it
- You can access it through SSH and everything
- Dokku is installed on it

## Connect to EC2

```
ssh -i ../aws/connect-to-bloodbath-in-ssh.pem ubuntu@108.129.41.141
```

## Troubleshooting

### SSL not working / LetsEncrypt not working

Disable the SSL on CloudFlare, it creates problems to access the endpoint in HTTP to activate the certificate itself.

### No space left on device, impossible to push via Dokku

Probably the logs accumulated while debugging for a while, simply remove /var/log to make some space in there.

You'll have to recreate /var/log/nginx/error.log and /var/log/nginx/access.log

### Unable to resolve host ip-X-X-X-X

Go in /etc/hosts and add

```
127.0.0.1 ip-X-X-X-X
```

It'll solve the problem manually

# Not to myself

If there's a problem and .env isn't loaded, do `touch .env` in the CLI, we should find an alternative or something