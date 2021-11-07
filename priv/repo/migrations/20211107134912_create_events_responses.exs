defmodule Bloodbath.Repo.Migrations.CreateEventsResponses do
  use Ecto.Migration

  def change do
    create table(:events_responses, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event_id, references(:events, on_delete: :delete_all, type: :binary_id), null: false

      add :type, :string, null: false # ok, error
      add :reason, :string # closed, etimedout
      add :body, :string
      add :headers, :map, default: %{}
      add :request_url, :string
      add :status_code, :integer

      timestamps()
    end
  end
end
