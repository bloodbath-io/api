defmodule Bigseat.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def change do
    create table(:bookings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :start_at, :utc_datetime, null: false
      add :end_at, :utc_datetime, null: false
      add :person_id, references(:people, on_delete: :delete_all, type: :binary_id), null: false
      add :space_id, references(:spaces, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:bookings, [:start_at, :end_at])
    create index(:bookings, [:space_id, :start_at, :end_at])
  end
end
