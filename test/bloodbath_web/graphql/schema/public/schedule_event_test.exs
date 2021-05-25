defmodule BloodbathWeb.Schema.ScheduleEventTest do
  use BloodbathWeb.ConnCase, async: true
  alias Bloodbath.Factory.{
    PersonFactory,
  }
  use Bloodbath.HelpersCase
  alias Bloodbath.CustomerEventsManagement.Event

  describe "schedule_event" do
    setup do
      [
        myself: PersonFactory.insert(:person, is_owner: true),
      ]
    end

    test "without authentication", %{conn: conn} do
      response = graphql_query(conn, %{query: query(), variables: variables()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, myself: myself} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: variables()}, :success)

      created_event = Event |> first() |> Repo.one()
      assert response == %{"data" => %{"scheduleEvent" => %{"id" => created_event.id}}}
    end


    defp query() do
      """
      mutation scheduleEvent(
        $body: String!
        $headers: String!
        $endpoint: String!
        $method: String!
        $scheduledFor:  DateTime!
      ) {
        scheduleEvent(
          body: $body
          headers: $headers
          endpoint: $endpoint
          method: $method
          scheduledFor: $scheduledFor
        ) {
          id
        }
      }

      """
    end

    def variables() do
      %{
        body: "any body",
        headers: "{\"test\": \"well\"}",
        endpoint: "https://test.com",
        method: "post",
        scheduled_for: "2021-05-09 00:04:34.025409Z"
      }
    end
  end
end