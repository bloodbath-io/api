defmodule Bloodbath.Repo do
  use Ecto.Repo,
    otp_app: :bloodbath,
    adapter: Ecto.Adapters.Postgres,
    pool_size: 100,
    timeout: 100_100_000,
    connect_timeout: 100_100_000,
    queue_target: 5000,
    queue_interval: 5000
end
