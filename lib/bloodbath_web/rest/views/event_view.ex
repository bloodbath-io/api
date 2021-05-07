defmodule BloodbathWeb.EventView do
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
    %{
      id: event.id,
      origin: event.origin,
      status: event.status,
      headers: event.headers,
      payload: event.payload,
      endpoint: event.endpoint,
      scheduled_for: event.scheduled_for,
      enqueued_at: event.enqueued_at,
      processed_at: event.processed_at
    }
  end
end
