defmodule Bigseat.Repo.Migrations.CreateIdentities do
  use Ecto.Migration

  def change do
    create table(:people, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string
      add :encrypted_password, :string
      add :first_name, :string
      add :last_name, :string
      add :is_admin, :boolean, default: false, null: false
      add :group, :string
      add :origin, :string, null: false
      add :type, :string, null: false
      add :organization_id, references(:organizations, on_delete: :delete_all, type: :binary_id), null: false
      add :api_key, :string, null: false
      add :password_recovery_token, :string

      timestamps()
    end

    create index(:people, [:organization_id])
    create unique_index(:people, [:organization_id, :email])
    create unique_index(:people, [:api_key])
  end
end
