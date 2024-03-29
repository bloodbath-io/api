defmodule BloodbathWeb.Schema.CancelEventTest do
  use BloodbathWeb.ConnCase, async: true
  alias Bloodbath.Factory.{
    EventFactory,
    PersonFactory
  }
  use Bloodbath.HelpersCase

  describe "add_new_team_member" do
    setup do
      myself = PersonFactory.insert(:person, is_owner: true)

      [
        myself: myself,
        event: EventFactory.insert(:event, organization: myself.organization)
      ]
    end

    test "without authentication", %{conn: conn, event: event} do
      response = graphql_query(conn, %{query: query(), variables: %{id: event.id}}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, myself: myself, event: event} do
      auth_conn = conn |> authorize(myself)
      response = graphql_query(auth_conn, %{query: query(), variables: %{id: event.id}}, :success)
      assert response == %{"data" => %{"cancelEvent" => %{"eventId" => event.id}}}
    end

    defp query() do
      """
      mutation cancelEvent(
        $id: UUID4!
      ) {
        cancelEvent(
          id: $id
        ) {
          eventId
        }
      }
      """
    end
  end
end
