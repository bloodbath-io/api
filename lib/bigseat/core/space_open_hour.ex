defmodule Bigseat.Core.SpaceOpenHour do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "space_open_hours" do
    belongs_to :space, Bigseat.Core.Space
    field :day_of_the_week, :string
    field :open_time, :time
    field :close_time, :time

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:day_of_the_week, :open_time, :close_time])
    |> validate_required([:day_of_the_week, :open_time, :close_time])
  end
end
