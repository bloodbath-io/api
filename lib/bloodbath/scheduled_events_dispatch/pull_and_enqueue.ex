defmodule Bloodbath.PullAndEnqueue do
  import Ecto.Query, warn: false
  use GenServer
  use Timex

  alias Bloodbath.Repo
  alias Bloodbath.CustomerEventsManagement.{
    Event,
  }

  @interval 30 * 1000 # every 30 seconds
  @buffer_lock 5 # this will lock it in advance
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
    event
    |> Event.update_changeset(%{enqueued_at: Timex.now})
    |> Repo.update()

    dispatch_time = DateTime.diff(event.scheduled_for, Timex.now()) - @buffer_lock
    countdown = if dispatch_time < 0 do
      0
    else
      dispatch_time
    end

    event |> start_dispatch_in(countdown)
  end

  defp start_dispatch_in(event, countdown) do
    {:ok, pid} = Bloodbath.LockAndDispatchEvent.start_link(%{event_id: event.id})
    Process.send_after(pid, :dispatch, countdown)
  end
end
