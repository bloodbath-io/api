defmodule Bloodbath.Customer.Event do
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  alias Bloodbath.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    belongs_to :person, Bloodbath.Customer.Person
    belongs_to :organization, Bloodbath.Customer.Organization
    field :scheduled_for, :utc_datetime
    field :enqueued_at, :utc_datetime
    field :dispatched_at, :utc_datetime
    field :origin, :string
    field :headers, :string
    field :payload, :string
    field :endpoint, :string

    timestamps()
  end

  def create_changeset(booking, attrs) do
    booking
    |> cast(attrs, [:scheduled_for, :origin, :headers, :payload, :endpoint])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
    |> validate_required([:scheduled_for, :origin, :headers, :payload, :endpoint])
  end

  def update_changeset(space, attrs) do
    space
    |> cast(attrs, [:enqueued_at, :dispatched_at])
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
