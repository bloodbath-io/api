defmodule Bloodbath.ScheduledEventsDispatch.LockAndDispatchEvent do
  require Logger
  use GenServer
  import Ecto.Query, warn: false

  alias Bloodbath.Repo
  alias Bloodbath.CustomerEventsManagement.{
    Event,
    EventResponse
  }

  @check_every 100 # milliseconds

  def start_link() do
    GenServer.start_link(__MODULE__, %{})
  end

  def handle_info(%{event_id: event_id}, state) do
    prepare_process(%{event_id: event_id})

    {:noreply, state}
  end

  def prepare_process(%{event_id: event_id}) do
    Logger.debug(%{resource: event_id, event: "Running inside process"})

    event_id |> set_locked
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

      # spawn(fn ->
        # if already_dispatched?(event.id) do
        #   Logger.debug(%{resource: event.id, event: "Dispatch was canceled at the last minute. The event seem to have been already processed."})
        # else
          event |> dispatch
        # end
      # end)
    end
  end

  @spec already_dispatched?(any) :: boolean
  def already_dispatched?(event_id) do
    # we rehydrate the event
    # in case it was altered at
    # some point in this timeframe
    event = Event |> Repo.get(event_id)

    if event.dispatched_at != nil do
      true
    else
      false
    end
  end

  def dispatch(event) do
    call_lambda(event)
    set_dispatched(event.id)
    Logger.debug(%{resource: event.id, event: "It was dispatched"})
    event
  end

  def set_dispatched(event_id) do
    Logger.debug(%{resource: event_id, event: "Updating dispatched_at"})

    query = from event in Event,
    where: event.id == ^event_id

    Repo.update_all(query, set: [dispatched_at: Timex.now()])
  end

  # we don't want race conditions so we lock it straight through ID
  # before getting it further in our logic
  defp set_locked(event_id) do
    query = from event in Event,
    where: event.id == ^event_id

    Logger.debug(%{resource: event_id, event: "Updating locked_at"})
    Repo.update_all(query, set: [locked_at: Timex.now()])
  end

  defp serialize_headers(headers) when is_nil(headers), do: []
  defp serialize_headers(headers) do
    Poison.decode!(headers)
  end

  defp call_lambda(event) do
    payload = %{
      id: event.id,
      body: event.body,
      endpoint: event.endpoint,
      headers: event.headers,
      method: event.method
    }

    context = %{}
    response = ExAws.Lambda.invoke("lock-and-dispatch-event", payload, context)
    |> ExAws.request(region: "eu-west-1")

    Logger.debug(%{resource: event.id, event: "Lambda was called", data: response})

    true
  end
end
