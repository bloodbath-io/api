defmodule BigseatWeb.Schema.CheckinSpaceTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory,
    SpaceFactory
  }
  use Bigseat.HelpersCase
  alias Bigseat.Core.Checkin

  describe "checkin space" do
    setup do
      team_member = PersonFactory.insert(:person, is_admin: false)
      space = SpaceFactory.insert(:space, organization: team_member.organization)

      [
        space: space,
        team_member: team_member
      ]
    end

    test "with an already existing person", %{
      conn: conn,
      space: space,
      team_member: team_member
    } do
      variables = %{
        space_id: space.id,
        person_id: team_member.id
      }

      response = graphql_query(conn, %{query: query(), variables: variables}, :success)
      created_checkin = Checkin |> where(person_id: ^team_member.id) |> Repo.one()
      assert response == %{"data" => %{
          "checkinSpace" => %{ "id" => created_checkin.id }
        }
      }
    end

    defp query() do
      """
      mutation checkinSpace(
        $spaceId: UUID4!
        $personId: UUID4!
      ) {
        checkinSpace(
          spaceId: $spaceId
          personId: $personId
        ) {
          id
        }
      }
      """
    end
  end
end
