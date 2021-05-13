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
    |> validate_required([:scheduled_for, :origin, :method, :headers, :payload, :endpoint])
  end

  def update_changeset(event, attrs) do
    event
    |> cast(attrs, [:enqueued_at, :locked_at, :dispatched_at])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
  end

  # def range(query, from, to) do
  #   from booking in query,
  #   where: (
  #       booking.scheduled_for >= ^from and booking.scheduled_for <= ^to
  #     ) or (
  #       booking.end_at >= ^from and booking.end_at <= ^to
  #     )
  # end
end
