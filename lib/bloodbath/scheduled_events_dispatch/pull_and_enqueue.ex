defmodule Bloodbath.ScheduledEventsDispatch.PullAndEnqueue do
  require Logger
  import Ecto.Query, warn: false
  use GenServer
  use Timex

  alias Bloodbath.Repo
  alias Bloodbath.CustomerEventsManagement.{
    Event,
  }

  @interval 15 * 1000 # seconds
  @buffer_lock 5 # this will lock it in advance
  @pull_events_from_the_next 60 # seconds

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:enqueue, state) do
    Logger.debug(%{event: "Going through loop enqueue"})
    pull_and_enqueue()
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :enqueue, @interval)
  end

  defp pull_and_enqueue() do
    spawn(fn ->
      query = from event in Event,
      where: is_nil(event.dispatched_at),
      where: is_nil(event.enqueued_at),
      where: event.scheduled_for <= ^in_the_next(),
      order_by: [asc: :scheduled_for]

      events = Repo.all(query)

      Logger.debug(%{count: length(events) ,event: "Events pulled"})
      _tasks = events |> Enum.map(&enqueue/1)
      # Task.await_many(tasks)
      Logger.debug(%{count: length(events),event: "All tasks finished"})
    end)
  end

  def in_the_next do
    Timex.now() |> Timex.shift(seconds: @pull_events_from_the_next)
  end

  def enqueue(event) do
    Logger.debug(%{resource: event.id, event: "Enqueued"})

    event
    |> Event.update_changeset(%{enqueued_at: Timex.now})
    |> Repo.update!()

    Logger.debug(%{resource: event.id, event: "We will calculate the difference between `#{event.scheduled_for}` and `#{Timex.now()}` and hold back for a while before locking the event"})
    dispatch_time = DateTime.diff(event.scheduled_for, Timex.now()) - @buffer_lock
    countdown_in_milliseconds = if dispatch_time < 0 do
      0
    else
      dispatch_time * 1000
    end

    Logger.debug(%{resource: event.id, event: "Will be dispatched in #{countdown_in_milliseconds}"})

    event |> start_dispatch_in(countdown_in_milliseconds)
  end

  defp start_dispatch_in(event, countdown_in_milliseconds) do
    Logger.debug(%{resource: event.id, event: "Will start link for the event"})
    {:ok, pid} = Bloodbath.ScheduledEventsDispatch.LockAndDispatchEvent.start_link()
    Logger.debug(%{resource: event.id, event: "Pid of process received"})
    Process.send_after(pid, %{event_id: event.id}, countdown_in_milliseconds)
    Logger.debug(%{resource: event.id, event: "Send after has been scheduled with the Pid on countdown #{countdown_in_milliseconds}"})
  end
end
