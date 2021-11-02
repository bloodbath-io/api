defmodule Bloodbath.ScheduledEventsDispatch.LockAndDispatchEvent do
  require Logger
  use Task
  import Ecto.Query, warn: false

  alias Bloodbath.Repo
  alias Bloodbath.CustomerEventsManagement.{
    Event,
  }

  @check_every 100 # milliseconds

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(%{event_id: event_id}) do
    Logger.debug(%{resource: event_id, event: "Running inside process"})

    event_id |> set_lock
    Logger.debug(%{resource: event_id, event: "Lock was set"})
    event = Event |> Repo.get(event_id)
    Logger.debug(%{resource: event_id, event: "Event get from repo"})

    case event do
      %Event{} -> event |> process
      _ ->
        Logger.debug(%{resource: event_id, event: "Event was not found"})
        {:error, "event not found"}
    end
  end

  def process(event) do
    if Timex.before?(Timex.now, event.scheduled_for) do
      Logger.debug(%{resource: event.id, event: "On hold"})
      :timer.sleep @check_every
      event |> process
    else
      Logger.debug(%{resource: event.id, event: "About to dispatch"})

      HTTPoison.start

      options = [
        # stream_to: self(),
        # async: :once,
        timeout: :infinity, # time we keep connections alive
        recv_timeout: :infinity # very large timeout on response, normal one is 5_000
        # max_connections: 100
      ]

      arguments = [
        event.endpoint,
        event.body,
        serialize_headers(event.headers),
        options
      ] |> Enum.reject(&is_nil/1)

      spawn(fn ->
        Logger.debug(%{resource: event.id, event: "Within the closure, ready to be dispatched"})
        # turns async, we could also use #spawn
        # to avoid locking the process
        response = HTTPoison |> apply(event.method, arguments)
        Logger.debug(%{resource: event.id, event: "Response received", payload: response})
      end)

      Logger.debug(%{resource: event.id, event: "It was dispatched"})

      event |> set_dispatch
    end
  end

  def set_dispatch(event) do
    Logger.debug(%{resource: event.id, event: "Updating dispatched_at"})

    event
    |> Event.update_changeset(%{dispatched_at: Timex.now})
    |> Repo.update()
  end

  # we don't want race conditions so we lock it straight through ID
  # before getting it further in our logic
  defp set_lock(event_id) do
    query = from event in Event,
    where: event.id == ^event_id

    Logger.debug(%{resource: event_id, event: "About to query the locked_at"})
    Repo.update_all(query, set: [locked_at: Timex.now()])
  end

  defp serialize_headers(headers) when is_nil(headers), do: []
  defp serialize_headers(headers) do
    Poison.decode!(headers)
  end
end
