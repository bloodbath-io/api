defmodule Bigseat.Core.Booking do
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  alias Bigseat.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "bookings" do
    belongs_to :person, Bigseat.Core.Person
    belongs_to :space, Bigseat.Core.Space
    field :start_at, :utc_datetime
    field :end_at, :utc_datetime

    timestamps()
  end

  def create_changeset(booking, attrs) do
    booking
    |> cast(attrs, [:start_at, :end_at])
    |> cast_assoc(:person)
    |> cast_assoc(:space)
    |> validate_required([:start_at, :end_at])
  end

  def update_changeset(space, attrs) do
    space
    |> cast(attrs, [:start_at, :end_at])
    |> cast_assoc(:person)
    |> cast_assoc(:space)
  end

  def range(query, from, to) do
    from booking in query,
    where: (
        booking.start_at >= ^from and booking.start_at <= ^to
      ) or (
        booking.end_at >= ^from and booking.end_at <= ^to
      )
  end
end
