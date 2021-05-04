defmodule BigseatWeb.Schema.ListCheckinsTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory,
    SpaceFactory,
    OrganizationFactory,
    CheckinFactory
  }
  use Bigseat.HelpersCase

  describe "list checkins" do
    setup do
      organization = OrganizationFactory.insert(:organization)
      myself = PersonFactory.insert(:person, is_admin: true, organization: organization)
      team_member = PersonFactory.insert(:person, is_admin: false, organization: organization)
      space = SpaceFactory.insert(:space, organization: organization)
      checkin = CheckinFactory.insert(:checkin, person: team_member, space: space)

      [
        checkin: checkin,
        myself: myself,
        team_member: team_member,
        space: space
      ]
    end

    test "get list of checkins without authentication", %{conn: conn} do
      response = graphql_query(conn, %{query: query()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "gets a checkin by id", %{conn: conn, checkin: checkin, space: space, myself: myself, team_member: team_member} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query()}, :success)
      assert response == %{
        "data" => %{
          "listCheckins" =>
          [
            %{"id" => "#{checkin.id}", "person" => %{"id" => team_member.id}, "space" => %{"id" => space.id}}
          ]
        }
      }
    end


    defp query do
      """
      query listCheckins {
        listCheckins {
          id
          person {
            id
          }
          space {
            id
          }
        }
      }
      """
    end
  end
end
