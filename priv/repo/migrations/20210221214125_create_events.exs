defmodule Bloodbath.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_at, :utc_datetime, null: false

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

    create index(:events, [:start_at])
    create index(:events, [:organization_id, :start_at])
    create index(:events, [:person_id, :start_at])
    create index(:events, [:organization_id, :status])
  end
end
