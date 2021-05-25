defmodule BloodbathWeb.EventControllerTest do
  use BloodbathWeb.ConnCase

  alias Bloodbath.Factory.{
    PersonFactory,
    EventFactory
  }

  alias Bloodbath.CustomerEventsManagement.{
    Event,
    Events
  }

  setup %{conn: conn} do
    myself = PersonFactory.insert(:person, is_owner: true)

    authorized_conn = conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "Bearer #{myself.api_key}")

    {:ok, conn: authorized_conn, myself: myself, organization: myself.organization}
  end

  describe "index" do
    test "lists all events", %{conn: conn} do
      conn = get(conn, Routes.event_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create event" do
    test "renders event when data is valid", %{conn: conn} do
      body = %{
        body: "{test: true}",
        headers: "{}",
        endpoint: "https://test.com",
        method: "post",
        scheduled_for: Timex.now |> Timex.shift(days: 1, hours: 1) |> DateTime.to_iso8601
      }

      conn = post(conn, Routes.event_path(conn, :create), body)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.event_path(conn, :show, id))
      event = Event |> first() |> Repo.one()

      matching = %{
        "id" => event.id,
        "endpoint" => "https://test.com",
        "enqueued_at" => nil,
        "headers" => "{}",
        "method" => "post",
        "origin" => "rest_api",
        "body" => "{test: true}",
        "dispatched_at" => nil,
        "scheduled_for" => "#{event.scheduled_for |> DateTime.to_iso8601}",
        "locked_at" => nil
      }

      require IEx; IEx.pry

      assert matching == json_response(conn, 200)["data"]
    end

  end

  describe "delete event" do
    test "deletes chosen event", %{conn: conn, myself: myself, organization: organization} do
      event = EventFactory.insert(:event, person: myself, organization: organization)
      conn = delete(conn, Routes.event_path(conn, :delete, event))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.event_path(conn, :show, event))
      end
    end
  end
end
