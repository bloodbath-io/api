defmodule Bigseat.Repo.Migrations.CreateCheckins do
  use Ecto.Migration

  def change do
    create table(:checkins, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :checked_at, :utc_datetime, null: false
      add :person_id, references(:people, on_delete: :delete_all, type: :binary_id), null: false
      add :space_id, references(:spaces, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:checkins, [:checked_at])
    create index(:checkins, [:space_id, :checked_at])
  end
end
