defmodule Bigseat.Repo.Migrations.PersonsPasswordTokens do
  use Ecto.Migration

  def change do
    create table(:people_password_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :token, :string, null: false
      add :person_id, references(:people, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:people_password_tokens, [:token])
  end
end
