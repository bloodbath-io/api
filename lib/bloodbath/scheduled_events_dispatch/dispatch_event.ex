defmodule Bloodbath.DispatchEvent do
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
    set_lock(event_id)
    event = Event |> Repo.get(event_id)

    case event do
      %Event{} -> process(event)
      _ -> {:error, "event not found"}
    end
  end

  def process(event) do
    if Timex.before?(Timex.now, event.scheduled_for) do
      IO.puts("On hold")
      :timer.sleep @check_every
      process(event)
    else
      IO.puts("About to dispatch #{event.id}")

      HTTPoison.start

      arguments = [event.endpoint, payload_of(event), headers_of(event)]
      method = event.method |> String.to_atom
      # turns async, we could also use #spawn
      # to avoid locking the process
      options = %{stream_to: self}
      apply(HTTPoison, method, arguments, options)

      IO.puts("#{event.id} was dispatched")

      set_dispatch(event)
    end

    {:ok}
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

  # TODO: everything below should be abstracted elsewhere
  # as we want to use it within the event validation itself
  defp payload_of(event) do
    Poison.decode!(event.payload)
  end

  defp headers_of(event) do
    headers_map = Poison.decode!(event.headers)
    headers_map |> Enum.map(fn {key, value} -> [key, value] end)
  end
end
