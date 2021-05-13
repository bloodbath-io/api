defmodule Bloodbath.PullAndEnqueue do
  import Ecto.Query, warn: false
  use GenServer
  use Timex

  alias Bloodbath.Repo
  alias Bloodbath.CustomerEventsManagement.{
    Event,
  }

  @interval 30 * 1000 # every 30 seconds
  @buffer_to_dispatch 1
  @pull_events_from_the_next 1 # minutes

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:enqueue, state) do
    pull_and_enqueue()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :enqueue, @interval)
  end

  defp pull_and_enqueue() do
    query = from event in Event,
    where: is_nil(event.dispatched_at),
    where: is_nil(event.enqueued_at),
    where: event.scheduled_for <= ^in_the_next()

    events = Repo.all(query)

    IO.puts "Events pulled: #{events |> length}"

    events |> Enum.each(&enqueue/1)
  end

  defp in_the_next do
    Timex.now() |> Timex.shift(minutes: @pull_events_from_the_next)
  end

  defp enqueue(event) do
    attributes = %{enqueued_at: Timex.now}
    Event.update_changeset(event, attributes)

    dispatch_time = DateTime.diff(event.scheduled_for, Timex.now()) - @buffer_to_dispatch
    dispatch_in = if dispatch_time < 0 do
      0
    else
      dispatch_time
    end

    {:ok, pid} = Bloodbath.DispatchEvent.start_link(%{event_id: event.id})
    Process.send_after(pid, :dispatch, dispatch_in)
  end
end
