defmodule Bloodbath.Core.Events do
  import Ecto.Query, warn: false
  alias Bloodbath.Repo

  alias Bloodbath.Core.{
    Event,
    Organization
  }

  def get!(id) do
    Event |> Repo.get!(id) |> Repo.preload([:person, :organization])
  end

  def get(id) do
    Event |> Repo.get(id) |> Repo.preload([:person, :organization])
  end

  def list do
    Event |> Repo.all() |> Repo.preload([:person, :organization])
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

  def delete(%Event{} = event) do
    Repo.delete(event)
  end
end
