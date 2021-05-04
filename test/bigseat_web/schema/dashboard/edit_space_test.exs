defmodule BigseatWeb.Schema.EditSpaceTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory,
    SpaceFactory
  }
  use Bigseat.HelpersCase

  describe "get_space" do
    setup do
      myself = PersonFactory.insert(:person, is_admin: true)

      [
        space: SpaceFactory.insert(:space, organization: myself.organization),
        myself: myself,
        person_from_another_organization: PersonFactory.insert(:person, is_admin: true)
      ]
    end

    test "without authentication", %{conn: conn, space: space} do
      response = graphql_query(conn, %{query: query(), variables: space |> variables(%{name: "Random name"})}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, space: space, myself: myself} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: space |> variables(%{name: "Random name"})}, :success)
      assert response == %{"data" => %{"editSpace" => %{"id" => "#{space.id}", "name" => "Random name"}}}
    end

    test "with authentication from another organization", %{conn: conn, space: space, person_from_another_organization: person} do
      auth_conn = conn |> authorize(person)

      response = graphql_query(auth_conn, %{query: query(), variables: space |> variables(%{name: "Random name"})}, :success)
      assert Map.has_key?(response, "errors")
    end


    defp query() do
      """
      mutation editSpace(
        $id: UUID4
        $spaceInput: SpaceInput!
      ) {
        editSpace(
          id: $id
          spaceInput: $spaceInput
        ) {
          id
          name
        }
      }
      """
    end

    def variables(space, space_input) do
      %{
        id: space.id,
        space_input: space_input
      }
    end
  end
end
