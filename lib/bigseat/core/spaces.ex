defmodule Bigseat.Core.Spaces do
  import Ecto.Query, warn: false
  alias Bigseat.Repo
  alias Ecto.Multi

  alias Bigseat.Core.{
    Space,
    Booking,
    Person,
    SpaceOpenHour,
    Organization
  }

  def get(id), do: Space |> Repo.get(id)
  def list, do: Space |> Repo.all() |> Repo.preload(:open_hours)

  def list_with_bookings(%Organization{} = organization, start_at, end_at) do
    query = from space in Space,
            left_join: booking in Booking, on: booking.space_id == space.id,
            left_join: person in Person, on: booking.person_id == person.id,
            where: space.organization_id == ^organization.id,
            where: booking.start_at >= ^start_at or booking.end_at <= ^end_at or is_nil(booking.id),
            order_by: booking.inserted_at,
            preload: [bookings: { booking, person: person }]

    Repo.all(query)
  end


  def create(params = %{ open_hours: open_hours_params }, organization_id) do
    space_params = Map.delete(params, :open_hours) |> Map.merge(%{organization_id: organization_id})
    changeset = %Space{} |> Space.create_changeset(space_params)

    multi = Multi.new
    |> Multi.insert(:space, changeset)
    |> Multi.run(:open_hours, fn _repo, %{space: space} ->
      open_hours = Enum.each open_hours_params, fn open_hour_param ->
        %SpaceOpenHour{}
        |> SpaceOpenHour.changeset(open_hour_param)
        |> Ecto.Changeset.put_assoc(:space, space)
        |> Repo.insert()
      end
      {:ok, open_hours}
    end)

    case Repo.transaction(multi) do
      {:ok, %{space: space}} -> {:ok, space}
      {:error, _model, changeset, _changes_so_far} -> {:error, changeset}
    end
  end

  def update(%Space{} = space, attrs) do
    space
    |> Space.update_changeset(attrs)
    |> Repo.update()
  end

  def delete(%Space{} = space) do
    Repo.delete(space)
  end
end
