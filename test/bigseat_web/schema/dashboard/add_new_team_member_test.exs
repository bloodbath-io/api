defmodule BigseatWeb.Schema.AddNewTeamMemberTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.PersonFactory
  use Bigseat.HelpersCase
  alias Bigseat.Core.{
    Person
  }

  describe "add_new_team_member" do
    setup do
      [
        myself: PersonFactory.insert(:person, is_admin: true),
      ]
    end

    test "without authentication", %{conn: conn} do
      response = graphql_query(conn, %{query: query(), variables: variables()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication and a taken email", %{conn: conn, myself: myself} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: variables() |> Map.merge(%{email: myself.email})}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication and a free email", %{conn: conn, myself: myself} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: variables()}, :success)
      person_created = Person |> where(is_admin: false) |> first() |> Repo.one()
      assert response == %{"data" => %{"addNewTeamMember" => %{"id" => person_created.id}}}
    end

    defp query() do
      """
      mutation addNewTeamMember(
        $email: String!
        $firstName: String!
        $lastName: String!
        $group: String!
        $origin: String!
      ) {
        addNewTeamMember(
          email: $email
          firstName: $firstName
          lastName: $lastName
          group: $group
          origin: $origin
        ) {
          id
        }
      }
      """
    end

    def variables() do
      %{
        email: "random@email.com",
        first_name: "Laurent",
        last_name: "Schaffner",
        group: "remote",
        origin: "native"
      }
    end
  end
end
