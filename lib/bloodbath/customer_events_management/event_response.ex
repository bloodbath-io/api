defmodule Bloodbath.CustomerEventsManagement.EventResponse do
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "events_responses" do
    belongs_to :event, Bloodbath.CustomerEventsManagement.Event
    field :type, Ecto.Enum, values: [:ok, :error]
    field :reason, :string
    field :body, :string
    field :headers, :map
    field :request_url, :string
    field :status_code, :integer

    timestamps([type: :utc_datetime_usec])
  end

  def create_changeset(event_response, attrs) do
    event_response
    |> cast(attrs, [:type, :reason, :body, :headers, :request_url, :status_code])
    |> cast_assoc(:event)
    |> validate_required([:type])
  end
end
