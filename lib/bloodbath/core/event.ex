defmodule Bloodbath.Core.Event do
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  alias Bloodbath.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "events" do
    belongs_to :person, Bloodbath.Core.Person
    belongs_to :organization, Bloodbath.Core.Organization
    field :start_at, :utc_datetime
    field :origin, :string
    field :status, :string
    field :headers, :string
    field :payload, :string
    field :endpoint, :string

    timestamps()
  end

  def create_changeset(booking, attrs) do
    booking
    |> cast(attrs, [:start_at, :origin, :status, :headers, :payload, :endpoint])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
    |> validate_required([:start_at, :origin, :status, :headers, :payload, :endpoint])
  end

  def update_changeset(space, attrs) do
    space
    |> cast(attrs, [:status])
    |> cast_assoc(:person)
    |> cast_assoc(:organization)
  end

  # def range(query, from, to) do
  #   from booking in query,
  #   where: (
  #       booking.start_at >= ^from and booking.start_at <= ^to
  #     ) or (
  #       booking.end_at >= ^from and booking.end_at <= ^to
  #     )
  # end
end
