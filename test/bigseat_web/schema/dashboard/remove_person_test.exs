defmodule BigseatWeb.Schema.RemovePersonTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.PersonFactory
  use Bigseat.HelpersCase

  describe "add_new_team_member" do
    setup do
      myself = PersonFactory.insert(:person, is_admin: true)
      [
        myself: myself,
        other_team_member: PersonFactory.insert(:person, email: "other-team-member@gmail.com", organization: myself.organization)
      ]
    end

    test "without authentication", %{conn: conn, other_team_member: other_team_member} do
      response = graphql_query(conn, %{query: query(), variables: %{id: other_team_member.id}}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, myself: myself, other_team_member: other_team_member} do
      auth_conn = conn |> authorize(myself)
      response = graphql_query(auth_conn, %{query: query(), variables: %{id: other_team_member.id}}, :success)
      assert response == %{"data" => %{"removePerson" => %{"id" => other_team_member.id}}}
    end

    defp query() do
      """
      mutation removePerson(
        $id: UUID4!
      ) {
        removePerson(
          id: $id
        ) {
          id
        }
      }
      """
    end
  end
end
