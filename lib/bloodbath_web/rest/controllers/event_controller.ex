defmodule BloodbathWeb.EventController do
  use BloodbathWeb, :controller

  alias Bloodbath.Core.Event
  alias Bloodbath.Core.Events

  action_fallback BloodbathWeb.FallbackController

  def index(conn, _params) do
    events = Events.list()
    render(conn, "index.json", events: events)
  end

  def create(conn, %{"event" => event_params}) do
    with {:ok, %Event{} = event} <- Events.create(event_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.event_path(conn, :show, event))
      |> render("show.json", event: event)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Events.get(id)
    render(conn, "show.json", event: event)
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get(id)

    with {:ok, %Event{}} <- Events.delete(event) do
      send_resp(conn, :no_content, "")
    end
  end
end
