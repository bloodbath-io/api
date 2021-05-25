defmodule Bloodbath.Repo.Migrations.ScheduleEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :scheduled_for, :utc_datetime, null: false
      add :enqueued_at, :utc_datetime, null: true
      add :locked_at, :utc_datetime, null: true
      add :dispatched_at, :utc_datetime, null: true

      add :origin, :string, null: false
      add :method, :string, null: false
      add :headers, :string, null: false
      add :body, :string, null: true
      add :endpoint, :string, null: false

      add :person_id, references(:people, on_delete: :delete_all, type: :binary_id), null: false
      add :organization_id, references(:organizations, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:events, [:origin])
    create index(:events, [:organization_id])

    create index(:events, [:scheduled_for])
    create index(:events, [:enqueued_at])
    create index(:events, [:dispatched_at])
    create index(:events, [:locked_at])
    create index(:events, [:organization_id, :scheduled_for])
    create index(:events, [:organization_id, :enqueued_at])
    create index(:events, [:organization_id, :dispatched_at])
    create index(:events, [:organization_id, :locked_at])
    create index(:events, [:dispatched_at, :enqueued_at, :scheduled_for])
  end
end
