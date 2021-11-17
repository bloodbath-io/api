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

# Access

[`localhost:4000`](http://localhost:4000)

# Other

## Upload a file with cURL

```
curl -X POST -F query="mutation { importTeamFromCsv(file: \"csv\") { id } }" -F csv=@team-members-list.csv localhost:4000/graphql
```

## Create uploader

```
mix arc.g avatar
```

## Dokku essentials

```
dokku postgres:expose bloodbath # expose database port to access it from any computer
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

# Production

## Connect to EC2

```
ssh -i ../aws/connect-to-bloodbath-in-ssh.pem ubuntu@108.129.41.141
```