defmodule BloodbathWeb.Schema.CreateEventTest do
  use BloodbathWeb.ConnCase, async: true
  alias Bloodbath.Factory.{
    PersonFactory,
  }
  use Bloodbath.HelpersCase
  alias Bloodbath.CustomerEventsManagement.Event

  describe "create_event" do
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
      assert response == %{"data" => %{"createEvent" => %{"id" => created_event.id}}}
    end


    defp query() do
      """
      mutation createEvent(
        $payload: String!
        $headers: String!
        $endpoint: String!
        $method: String!
        $scheduledFor:  DateTime!
      ) {
        createEvent(
          payload: $payload
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
        payload: "{test: true}",
        headers: "{}",
        endpoint: "https://test.com",
        method: "get",
        scheduled_for: "2021-05-09 00:04:34.025409Z"
      }
    end
  end
end
