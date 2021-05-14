defmodule Bloodbath.ScheduledEventsDispatch.LockAndDispatchEvent do
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
    event_id |> set_lock
    event = Event |> Repo.get(event_id)

    case event do
      %Event{} -> event |> process
      _ -> {:error, "event not found"}
    end
  end

  def process(event) do
    if Timex.before?(Timex.now, event.scheduled_for) do
      IO.puts("On hold")
      :timer.sleep @check_every
      event |> process
    else
      IO.puts("About to dispatch #{event.id}")

      HTTPoison.start

      # options = [
      #   stream_to: self(),
      #   async: :once,
      #   timeout: 50_000,
      #   recv_timeout: 50_000
      # ]

      arguments = [
        event.endpoint,
        event.body,
        serialize_headers(event.headers),
        # options
      ] |> Enum.reject(&is_nil/1)

      spawn(fn ->
        # turns async, we could also use #spawn
        # to avoid locking the process
        HTTPoison |> apply(event.method, arguments)
      end)

      IO.puts("#{event.id} was dispatched")

      event |> set_dispatch
    end
  end

  def set_dispatch(event) do
    event
    |> Event.update_changeset(%{dispatched_at: Timex.now})
    |> Repo.update()
  end

  # we don't want race conditions so we lock it straight through ID
  # before getting it further in our logic
  defp set_lock(event_id) do
    query = from event in Event,
    where: event.id == ^event_id

    Repo.update_all(query, set: [locked_at: Timex.now()])
  end

  defp serialize_headers(headers) when is_nil(headers), do: []
  defp serialize_headers(headers) do
    Poison.decode!(headers)
  end
end
