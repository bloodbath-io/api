defmodule BloodbathWeb.Schema.GetSpaceTest do
  use BloodbathWeb.ConnCase, async: true
  alias Bloodbath.Factory.{
    PersonFactory,
    SpaceFactory
  }
  use Bloodbath.HelpersCase

  describe "get_space" do
    setup do
      [
        space: SpaceFactory.insert(:space),
        myself: PersonFactory.insert(:person, is_owner: true)
      ]
    end

    test "without authentication", %{conn: conn, space: space} do
      response = graphql_query(conn, %{query: query(), variables: space |> variables()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "by id", %{conn: conn, space: space, myself: myself} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: space |> variables()}, :success)
      assert response == %{"data" => %{"getSpace" => %{"id" => "#{space.id}"}}}
    end

    defp query() do
      """
      query(
        $id: UUID4!
      ) {
        getSpace(id: $id) {
          id
        }
      }
      """
    end

    def variables(space) do
      %{
        id: space.id
      }
    end
  end
end
