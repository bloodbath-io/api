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

    # because headers can be received in string format (cURL) or in tuple (libraries)
    # we normalize it before going further (this can be extended to other params if need be)
    # TODO : put that in top of create_changeset inside event.ex instead of here
    # it can be altered before the rest
    normalized_params = case params do
      %{ headers: %{} } ->
        encoded_headers = Poison.encode!(params.headers)
        params |> Map.merge(%{headers: encoded_headers})
      _ ->
        params
    end

    schedule_event = %Event{} |> Event.create_changeset(normalized_params)
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
      _ -> {:error, "Event can't be removed"}
    end
  end
end
