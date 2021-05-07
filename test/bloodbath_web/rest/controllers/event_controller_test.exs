defmodule BloodbathWeb.EventControllerTest do
  use BloodbathWeb.ConnCase

  alias Bloodbath.Core.Event
  alias Bloodbath.Core.Events
  alias Bloodbath.Factory.{
    PersonFactory,
    EventFactory
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
      conn = post(conn, Routes.event_path(conn, :create), event: %{
        payload: "{test: true}",
        headers: "{}",
        endpoint: "https://test.com",
        scheduled_for: "2021-05-09 00:04:34.025409Z"
      })

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.event_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "name" => "some name",
               "tag" => "some tag"
             } = json_response(conn, 200)["data"]
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
