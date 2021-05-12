defmodule Bloodbath.Customer.Events do
  import Ecto.Query, warn: false
  alias Bloodbath.Repo

  alias Bloodbath.Customer.{
    Event,
    Organization
  }

  def get!(person, id) do
    Event |> where(id: ^id) |> where(organization_id: ^person.organization_id) |> Repo.one!() |> Repo.preload([:person, :organization])
  end

  def get(person, id) do
    Event |> where(id: ^id) |> where(organization_id: ^person.organization_id) |> Repo.one() |> Repo.preload([:person, :organization])
  end

  def list(person) do
    Event |> where(organization_id: ^person.organization_id) |> Repo.all() |> Repo.preload([:person, :organization])
  end

  def create(person, params) do
    organization = Organization |> Repo.get(person.organization_id)

    %Event{}
    |> Event.create_changeset(params)
    |> Ecto.Changeset.put_assoc(:organization, organization)
    |> Ecto.Changeset.put_assoc(:person, person)
    |> Repo.insert()
  end

  def update(%Event{} = event, params) do
    event
    |> Event.update_changeset(params)
    |> Repo.update()
  end

  def delete(person, id) do
    query = from event in Event,
            where: event.organization_id == ^person.organization_id,
            where: is_nil(event.dispatched_at)

    event = Repo.one(query)

    case event do
      %Event{} -> Repo.delete(event)
      _ -> {:error, "event not found"}
    end
  end
end
