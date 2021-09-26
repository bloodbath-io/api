defmodule BloodbathWeb.Schema.EventTest do
  use BloodbathWeb.ConnCase, async: true
  alias Bloodbath.Factory.{
    PersonFactory,
    EventFactory,
    OrganizationFactory
  }
  use Bloodbath.HelpersCase

  describe "event" do
    setup do
      organization = OrganizationFactory.insert(:organization)
      myself = PersonFactory.insert(:person, is_owner: true, organization: organization)
      event = EventFactory.insert(:event, person: myself, organization: organization)

      [
        event: event,
        myself: myself
      ]
    end

    test "without authentication", %{conn: conn, event: event} do
      response = graphql_query(conn, %{query: query(), variables: event |> variables()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "by id", %{conn: conn, event: event, myself: myself} do
      auth_conn = conn |> authorize(myself)

      IO.inspect %{query: query(), variables: event |> variables()}

      response = graphql_query(auth_conn, %{query: query(), variables: event |> variables()}, :success)
      assert Map.has_key?(response, "data")
    end

    defp query() do
      """
      query getEvent($id: ID!) {
        node(id: $id) {
          id
          ... on PublicEvent {
            method
          }
        }
      }
      """
    end

    def variables(event) do
      %{
        id: event.id
      }
    end
  end
end
