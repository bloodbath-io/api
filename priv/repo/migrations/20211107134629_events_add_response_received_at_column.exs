defmodule Bloodbath.Repo.Migrations.EventsAddResponseReceivedAtColumn do
  use Ecto.Migration

  def change do
    alter table("events") do
      add :response_received_at, :utc_datetime
    end

    create index(:events, [:response_received_at])
  end
end
