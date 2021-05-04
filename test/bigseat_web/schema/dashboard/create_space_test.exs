defmodule BigseatWeb.Schema.CreateSpaceTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory,
  }
  use Bigseat.HelpersCase
  alias Bigseat.Core.Space

  describe "create_space" do
    setup do
      [
        myself: PersonFactory.insert(:person, is_admin: true),
      ]
    end

    test "without authentication", %{conn: conn} do
      response = graphql_query(conn, %{query: query(), variables: variables()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, myself: myself} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: variables(), file: avatar()}, :success)

      created_space = Space |> first() |> Repo.one()
      assert response == %{"data" => %{"createSpace" => %{"id" => created_space.id}}}
    end


    defp query() do
      """
      mutation createSpace(
        $openHours: OpenHoursInput!
        $avatar: Upload
      ) {
        createSpace(
          avatar: $avatar,
          name: "My space",
          openHours: $openHours,
          maximumPeople: 10
          dailyCheckin: true
        ) {
          id
        }
      }
      """
    end

    def avatar() do
      %Plug.Upload{path: "test/support/files/valid-space-avatar.png", filename: "valid-space-avatar.png"}
    end

    def variables() do
      %{
        avatar: "file",
        open_hours: [%{
          day_of_the_week: "monday",
          open_time: "10:59:40Z",
          close_time: "20:59:40Z"
        }]
      }
    end
  end
end
