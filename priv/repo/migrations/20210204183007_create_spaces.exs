defmodule Bigseat.Repo.Migrations.CreateSpaces do
  use Ecto.Migration

  def change do
    create table(:spaces, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :name, :string, null: false
      add :avatar, :string
      add :maximum_people, :integer, null: false
      add :daily_checkin, :boolean, null: false
      add :organization_id, references(:organizations, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:spaces, [:organization_id])
    create unique_index(:spaces, [:organization_id, :slug])
  end
end
