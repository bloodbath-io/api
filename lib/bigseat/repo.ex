defmodule Bigseat.Repo do
  use Ecto.Repo,
    otp_app: :bigseat,
    adapter: Ecto.Adapters.Postgres
end
