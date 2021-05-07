defmodule Bloodbath.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :scheduled_for, :utc_datetime, null: false
      add :enqueued_at, :utc_datetime, null: true
      add :processed_at, :utc_datetime, null: true

      add :origin, :string, null: false
      add :status, :string, null: false
      add :headers, :string, null: false
      add :payload, :string, null: false
      add :endpoint, :string, null: false

      add :person_id, references(:people, on_delete: :delete_all, type: :binary_id), null: false
      add :organization_id, references(:organizations, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:events, [:origin])
    create index(:events, [:organization_id])

    create index(:events, [:scheduled_for])
    create index(:events, [:organization_id, :scheduled_for])
    create index(:events, [:person_id, :scheduled_for])
    create index(:events, [:organization_id, :status])
  end
end
