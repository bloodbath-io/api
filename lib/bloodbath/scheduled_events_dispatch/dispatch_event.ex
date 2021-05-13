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
    if Timex.now > event.scheduled_for do
      :timer.sleep @check_every
      process(event)
    else
      IO.puts("PROCESSING EVENT #{event.id}")

      # POST
      # GET
      # PUT
      # PATCH
      # DELETE

      # HTTPoison.start
      # HTTPoison.patch(url, body, headers, options)
      # HTTPoison.post "http://httparrot.herokuapp.com/post", "{\"body\": \"test\"}", [{"Content-Type", "application/json"}]

      # set_dispatched(event)
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

    Repo.update_all(Event, set: [locked_at: Timex.now()])
  end
end
