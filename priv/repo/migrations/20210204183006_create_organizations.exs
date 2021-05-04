defmodule Bloodbath.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :slug, :string, null: false
      add :name, :string, null: false
      add :api_key, :string, null: false

      timestamps()
    end

    create unique_index(:organizations, [:slug])
    create unique_index(:organizations, [:api_key])
  end
end
