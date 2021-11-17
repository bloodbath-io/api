defmodule Bloodbath.Repo do
  use Ecto.Repo,
    otp_app: :bloodbath,
    adapter: Ecto.Adapters.Postgres
end
