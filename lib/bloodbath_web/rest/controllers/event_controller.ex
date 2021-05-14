defmodule BloodbathWeb.EventController do
  use BloodbathWeb, :controller

  alias Bloodbath.CustomerEventsManagement.Event
  alias Bloodbath.CustomerEventsManagement.Events

  action_fallback BloodbathWeb.FallbackController

  def index(conn, _params) do
    events = Events.list(conn |> myself())
    render(conn, "index.json", events: events)
  end

  def create(conn, params) do
    attributes = params |> Map.merge(%{"origin" => "rest_api"}) |> strings_to_atoms
    create_event = Events.create(conn |> myself, attributes)
    with {:ok, %Event{} = event} <- create_event do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.event_path(conn, :show, event))
      |> render("show.json", event: event)
    else
      error -> error
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

  def strings_to_atoms(string_key_map) do
    for {key, value} <- string_key_map, into: %{}, do: {String.to_atom(key), value}
  end
end
