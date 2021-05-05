defmodule BloodbathWeb.Schema.CreateEventTest do
  use BloodbathWeb.ConnCase, async: true
  alias Bloodbath.Factory.{
    PersonFactory,
  }
  use Bloodbath.HelpersCase
  alias Bloodbath.Core.Event

  describe "create_event" do
    setup do
      [
        myself: PersonFactory.insert(:person, is_owner: true),
      ]
    end

    test "without authentication", %{conn: conn} do
      response = graphql_query(conn, %{query: query(), variables: variables()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, myself: myself} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: variables(), file: avatar()}, :success)

      created_event = Event |> first() |> Repo.one()
      assert response == %{"data" => %{"createEvent" => %{"id" => created_event.id}}}
    end


    defp query() do
      """
      mutation createEvent(
        $openHours: OpenHoursInput!
        $avatar: Upload
      ) {
        createEvent(
          avatar: $avatar,
          name: "My event",
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
      %Plug.Upload{path: "test/support/files/valid-event-avatar.png", filename: "valid-event-avatar.png"}
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
