defmodule Bloodbath.CustomerEventsManagement.Event do
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  alias Bloodbath.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    belongs_to :person, Bloodbath.AccountManagement.Person
    belongs_to :organization, Bloodbath.AccountManagement.Organization
    field :scheduled_for, :utc_datetime
    field :enqueued_at, :utc_datetime
    field :locked_at, :utc_datetime
    field :dispatched_at, :utc_datetime
    field :method, :string
    field :origin, :string
    field :headers, :string
    field :payload, :string
    field :endpoint, :string

    timestamps()
  end

  def create_changeset(event, attrs) do
    event
    |> cast(attrs, [:scheduled_for, :origin, :method, :headers, :payload, :endpoint])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
    |> validate_required([:scheduled_for, :origin, :method, :headers, :endpoint])
    |> payload_checks(attrs)
  end

  def update_changeset(event, attrs) do
    event
    |> cast(attrs, [:enqueued_at, :locked_at, :dispatched_at])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
  end

  defp payload_checks(changeset, attrs) do
    if attrs.method in ["get", "delete"] && Map.has_key?(attrs, :payload) do
      add_error(changeset, :payload, "can't be set using the #{attrs.method} method")
    else
      changeset
    end
  end
end
