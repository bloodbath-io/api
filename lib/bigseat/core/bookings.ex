defmodule Bigseat.Core.Bookings do
  import Ecto.Query, warn: false
  alias Bigseat.Repo

  alias Bigseat.Core.{
    Booking,
    Organization,
    Person
  }

  def get(id), do: Booking |> Repo.get(id) |> Repo.preload([:person, :space])
  def list, do: Booking |> Repo.all() |> Repo.preload([:person, :space])

  def create(space, person_params = %{email: _email, first_name: _first_name, last_name: _last_name}, params = %{start_at: start_at, end_at: end_at}) do
    with {:ok} <- capacity_not_reached?(space, start_at, end_at),
         {:ok, person} <- find_or_create_person(space.organization_id, person_params),
         {:ok} <- already_booked?(space, person, start_at, end_at) do
          %Booking{}
          |> Booking.create_changeset(params)
          |> Ecto.Changeset.put_assoc(:space, space)
          |> Ecto.Changeset.put_assoc(:person, person)
          |> Repo.insert()
    end
  end

  defp find_or_create_person(organization_id, params = %{email: email, first_name: _first_name, last_name: _last_name}) do
    person = Person |> where(email: ^email) |> where(organization_id: ^organization_id) |> Repo.one()
    case person do
      %Person{} -> {:ok, person}
      _ ->
        organization = Organization |> Repo.get(organization_id)
        %Person{}
        |> Person.create_changeset(Map.merge(params, %{is_admin: false, type: "Guest", group: :remote, origin: "native"}))
        |> Ecto.Changeset.put_assoc(:organization, organization)
        |> Repo.insert()
    end
  end

  defp capacity_not_reached?(space, start_at, end_at) do
    bookings_count = Booking |> Booking.range(start_at, end_at) |> Repo.aggregate(:count, :id)
    if bookings_count >= space.maximum_people do
      {:error, "maximum people reached for this space (#{space.maximum_people})"}
    else
      {:ok}
    end
  end

  defp already_booked?(space, person, start_at, end_at) do
    bookings_from_person = Booking
    |> Booking.range(start_at, end_at)
    |> where(person_id: ^person.id)
    |> where(space_id: ^space.id)
    |> Repo.aggregate(:count, :id)

    if bookings_from_person > 0 do
      {:error, "space already booked for this person"}
    else
      {:ok}
    end
  end

  def update(%Booking{} = booking, attrs) do
    booking
    |> Booking.update_changeset(attrs)
    |> Repo.update()
  end

  def delete(%Booking{} = booking) do
    Repo.delete(booking)
  end
end
