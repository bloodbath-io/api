defmodule BloodbathWeb.EventView do
  require Logger
  use BloodbathWeb, :view
  alias BloodbathWeb.EventView

  def render("index.json", %{events: events}) do
    %{
      data: render_many(events, EventView, "event.json")
    }
  end

  def render("show.json", %{event: event}) do
    %{
      data: render_one(event, EventView, "event.json")
    }
  end

  def render("event.json", %{event: event}) do
    Logger.debug(%{resource: event.id, event: "About to render event (and give response to sender)"})

    %{
      id: event.id,
      origin: event.origin,
      headers: event.headers,
      body: event.body,
      method: event.method,
      endpoint: event.endpoint,
      scheduled_for: event.scheduled_for,
      enqueued_at: event.enqueued_at,
      locked_at: event.locked_at,
      dispatched_at: event.dispatched_at
    }
  end

  def render("delete.json", %{}) do
    %{
      data: nil
    }
  end
end
