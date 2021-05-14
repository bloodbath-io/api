defmodule Bloodbath.CustomerEventsManagement.Events do
  import Ecto.Query, warn: false
  alias Bloodbath.Repo

  alias Bloodbath.CustomerEventsManagement.{
    Event,
  }

  alias Bloodbath.AccountManagement.{
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

    with {:ok, %Event{} = event} <- %Event{}
    |> Event.create_changeset(params)
    |> Ecto.Changeset.put_assoc(:organization, organization)
    |> Ecto.Changeset.put_assoc(:person, person)
    |> Repo.insert() do
      # if we should enqueue it immediatly
      # and not wait for the loop
      if Timex.before?(event.scheduled_for, Bloodbath.ScheduledEventsDispatch.PullAndEnqueue.in_the_next()) do
        Bloodbath.ScheduledEventsDispatch.PullAndEnqueue.enqueue(event)
      end
      {:ok, event}
    end
  end

  def delete(person, id) do
    query = from event in Event,
            where: event.organization_id == ^person.organization_id,
            where: is_nil(event.locked_at)

    event = Repo.one(query)

    case event do
      %Event{} -> Repo.delete(event)
      _ -> {:error, "event not found"}
    end
  end
end
