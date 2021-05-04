defmodule Bigseat.Core.Checkin do
  import Ecto.Changeset
  import Ecto.Query, warn: false
  use Ecto.Schema
  alias Bigseat.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "checkins" do
    belongs_to :person, Bigseat.Core.Person
    belongs_to :space, Bigseat.Core.Space
    field :checked_at, :utc_datetime

    timestamps()
  end

  def create_changeset(checkin, attrs) do
    checkin
    |> cast(attrs, [:checked_at])
    |> cast_assoc(:person)
    |> cast_assoc(:space)
    |> validate_required([:checked_at])
  end

  def update_changeset(space, attrs) do
    space
    |> cast(attrs, [:checked_at])
    |> cast_assoc(:person)
    |> cast_assoc(:space)
  end

  def range(query, from, to) do
    from checkin in query,
    where: checkin.checked_at >= ^from and checkin.checked_at <= ^to
  end
end
