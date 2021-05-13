defmodule Bloodbath.DispatchEvent do
  use Task

  alias Bloodbath.Repo
  alias Bloodbath.CustomerEventsManagement.{
    Event,
  }

  def start_link(arg) do
    Task.start_link(__MODULE__, :run, [arg])
  end

  def run(arg) do
    event = Event |> Repo.get(arg[:event_id])
    case event do
      %Event{} -> process(event)
      _ -> {:error, "event not found"}
    end
  end

  def process(event) do
    # HERE IS THE DISPATCH LOGIC
    IO.puts("PROCESSING EVENT #{event.id}")
    {:ok}
  end
end
