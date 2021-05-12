defmodule BloodbathWeb.EventController do
  use BloodbathWeb, :controller

  alias Bloodbath.Customer.Event
  alias Bloodbath.Customer.Events

  action_fallback BloodbathWeb.FallbackController

  def index(conn, _params) do
    events = Events.list(conn |> myself())
    render(conn, "index.json", events: events)
  end

  def create(conn, params) do
    attributes = params |> Map.merge(%{"origin" => "rest_api"})

    with {:ok, %Event{} = event} <- Events.create(conn |> myself, attributes) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.event_path(conn, :show, event))
      |> render("show.json", event: event)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Events.get!(conn |> myself, id)
    render(conn, "show.json", event: event)
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, %Event{}} <- Events.delete(conn |> myself, id) do
      send_resp(conn, :no_content, "")
    end
  end

  def myself(conn) do
    conn.assigns[:rest][:context][:myself]
  end
end
