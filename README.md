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
## Dokku essentials

```
dokku postgres:expose bloodbath # expose database port to access it from any computer
```

## Deploy in production

```
git push dokku
```

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