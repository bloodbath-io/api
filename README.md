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
-- check the difference / error rate in terms of second on what was planned
select avg(DATE_PART('second', scheduled_for::date) - DATE_PART('second', dispatched_at::date)) as avg_seconds from events
```