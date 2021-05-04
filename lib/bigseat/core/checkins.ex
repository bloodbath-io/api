defmodule Bigseat.Core.Checkins do
  import Ecto.Query, warn: false
  alias Bigseat.Repo

  alias Bigseat.Core.{
    Checkin,
  }

  def get(id), do: Checkin |> Repo.get(id) |> Repo.preload([:person, :space])
  def list, do: Checkin |> Repo.all() |> Repo.preload([:person, :space])

  def create(space, person) do
    checked_at = Timex.now
    with {:ok} <- person_from_space_organization?(person, space) do
      %Checkin{}
      |> Checkin.create_changeset(%{checked_at: checked_at})
      |> Ecto.Changeset.put_assoc(:space, space)
      |> Ecto.Changeset.put_assoc(:person, person)
      |> Repo.insert()
    end
  end

  defp person_from_space_organization?(person, space) do
    if person.organization_id != space.organization_id do
      {:error, "person not from the space organization"}
    else
      {:ok}
    end
  end

  def update(%Checkin{} = checkin, attrs) do
    checkin
    |> Checkin.update_changeset(attrs)
    |> Repo.update()
  end

  def delete(%Checkin{} = checkin) do
    Repo.delete(checkin)
  end
end
