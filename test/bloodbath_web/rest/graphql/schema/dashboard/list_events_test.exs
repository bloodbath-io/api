defmodule BloodbathWeb.Schema.ListEventsTest do
  use BloodbathWeb.ConnCase, async: true
  alias Bloodbath.Factory.{
    PersonFactory,
    EventFactory,
    OrganizationFactory
  }
  use Bloodbath.HelpersCase

  describe "list events" do
    setup do
      organization = OrganizationFactory.insert(:organization)
      myself = PersonFactory.insert(:person, is_owner: true, organization: organization)
      event = EventFactory.insert(:event, person: myself, organization: organization)

      [
        event: event,
        myself: myself,
        organization: organization
      ]
    end

    test "get list of events without authentication", %{conn: conn} do
      response = graphql_query(conn, %{query: query()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "gets a event by id", %{conn: conn, event: event, myself: myself, organization: organization} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query()}, :success)
      assert response == %{
        "data" => %{
          "listEvents" =>
          [
            %{"id" => "#{event.id}", "person" => %{"id" => myself.id}, "organization" => %{"id" => organization.id}}
          ]
        }
      }
    end


    defp query do
      """
      query listEvents {
        listEvents {
          id
          person {
            id
          }
          organization {
            id
          }
        }
      }
      """
    end
  end
end
