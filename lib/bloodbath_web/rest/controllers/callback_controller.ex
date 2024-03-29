defmodule BloodbathWeb.CallbackController do
  require Logger
  use BloodbathWeb, :controller

  action_fallback BloodbathWeb.FallbackController

  alias Bloodbath.Repo
  alias Bloodbath.CustomerEventsManagement.{
    Event,
    EventResponse
  }

  def create(conn, params) do
    event_id = params["id"]
    event = Event |> Repo.get(event_id)

    event |> set_response
    insert_full_response(event, params["type"], params["body"], params["status"], params["headers"], params["reason"])

    render(conn, "index.json")
  end

  def set_response(event) do
    Logger.debug(%{resource: event.id, event: "Updating response_received_at"})

    event |> Event.update_changeset(%{response_received_at: Timex.now})
    |> Repo.update!()
  end

  def insert_full_response(event, type, body, status, headers, reason) do
    attrs = %{
      type: type,
      body: body,
      headers: headers,
      request_url: event.endpoint,
      status_code: status,
      reason: reason
    }

    Logger.debug(%{resource: event.id, event: "Ok received, we will create an EventResponse for it", data: attrs})

    %EventResponse{} |> EventResponse.create_changeset(attrs)
    |> Ecto.Changeset.put_assoc(:event, event)
    |> Repo.insert!()
  end
end
