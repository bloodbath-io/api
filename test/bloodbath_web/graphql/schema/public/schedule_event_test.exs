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
      response = graphql_query(conn, %{query: query(), variables: variables(%{ scheduled_for: nil })}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, myself: myself} do
      auth_conn = conn |> authorize(myself)
      response = graphql_query(auth_conn, %{query: query(), variables: variables(%{ scheduled_for: nil })}, :success)

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

    def variables(%{ scheduled_for: scheduled_for }) do
      %{
        body: "any body",
        headers: "{\"test\": \"well\"}",
        endpoint: "https://test.com",
        method: "post",
        scheduled_for: scheduled_for || Timex.now |> Timex.shift(days: 1, hours: 1) |> DateTime.to_iso8601
      }
    end
  end
end
