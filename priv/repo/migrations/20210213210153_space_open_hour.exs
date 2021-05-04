defmodule Bigseat.Repo.Migrations.SpaceOpenHour do
  use Ecto.Migration

  def change do
    create table(:space_open_hours, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :day_of_the_week, :string, null: false
      add :open_time, :time, null: false
      add :close_time, :time, null: false
      add :space_id, references(:spaces, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:space_open_hours, [:space_id])
  end
end
