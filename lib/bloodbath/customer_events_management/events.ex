defmodule Bloodbath.CustomerEventsManagement.Events do
  import Ecto.Query, warn: false
  alias Bloodbath.Repo

  alias Bloodbath.CustomerEventsManagement.{
    Event,
  }

  alias Bloodbath.AccountManagement.{
    Organization
  }

  def find!(person, id) do
    Event |> where(id: ^id) |> where(organization_id: ^person.organization_id) |> Repo.one!() |> Repo.preload([:person, :organization])
  end

  def find(person, id) do
    Event |> where(id: ^id) |> where(organization_id: ^person.organization_id) |> Repo.one() |> Repo.preload([:person, :organization])
  end

  def list(person) do
    Event |> where(organization_id: ^person.organization_id) |> order_by(desc: :inserted_at) |> Repo.all() |> Repo.preload([:person, :organization])
  end

  def schedule(person, params) do
    organization = Organization |> Repo.get(person.organization_id)

    schedule_event = %Event{} |> Event.create_changeset(params)
    |> Ecto.Changeset.put_assoc(:organization, organization)
    |> Ecto.Changeset.put_assoc(:person, person)
    |> Repo.insert()

    with {:ok, %Event{} = event} <- schedule_event do
      # if we should enqueue it immediatly
      # and not wait for the loop
      if Timex.before?(event.scheduled_for, Bloodbath.ScheduledEventsDispatch.PullAndEnqueue.in_the_next()) do
        Bloodbath.ScheduledEventsDispatch.PullAndEnqueue.enqueue(event)
      end
      {:ok, event}
    else
      error -> error
    end
  end

  def cancel(person, id) do
    query = from event in Event,
            where: event.id == ^id,
            where: event.organization_id == ^person.organization_id,
            where: is_nil(event.locked_at)

    event = Repo.one(query)

    case event do
      %Event{} -> Repo.delete(event)
      _ -> {:error, "Event can't be removed. Are you sure it still exist?"}
    end
  end
end
