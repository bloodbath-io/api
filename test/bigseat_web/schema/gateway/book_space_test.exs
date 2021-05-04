defmodule BigseatWeb.Schema.BookSpaceTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory,
    SpaceFactory,
    BookingFactory
  }
  use Bigseat.HelpersCase
  alias Bigseat.Core.Booking

  describe "book space" do
    setup do
      person = PersonFactory.insert(:person, is_admin: true)
      team_member = PersonFactory.insert(:person, is_admin: false)
      space = SpaceFactory.insert(:space, organization: person.organization)
      booking = BookingFactory.insert(:booking, space: space, person: team_member)
      space_without_booking = SpaceFactory.insert(:space, organization: person.organization)

      [
        space: space,
        space_without_booking: space_without_booking,
        booking: booking,
        person: person,
        team_member: team_member
      ]
    end

    test "with an already existing person", %{
      conn: conn,
      booking: booking,
      space_without_booking: space_without_booking,
      team_member: team_member
    } do
      variables = %{
        start_at: booking.start_at |> Timex.shift(hours: -1) |> Timex.format!("{ISO:Extended}"),
        end_at: booking.start_at |> Timex.shift(hours: 1) |> Timex.format!("{ISO:Extended}"),
        space_id: space_without_booking.id,
        person: %{
          email: team_member.email,
          first_name: "First name",
          last_name: "Last name"
        }
      }

      response = graphql_query(conn, %{query: query(), variables: variables}, :success)
      created_booking = Booking |> where(space_id: ^space_without_booking.id) |> Repo.one()
      assert response == %{"data" => %{
          "bookSpace" => %{ "id" => created_booking.id }
        }
      }
    end

    test "with a new person", %{
      conn: conn,
      booking: booking,
      space_without_booking: space_without_booking
    } do
      variables = %{
        start_at: booking.start_at |> Timex.shift(hours: -1) |> Timex.format!("{ISO:Extended}"),
        end_at: booking.start_at |> Timex.shift(hours: 1) |> Timex.format!("{ISO:Extended}"),
        space_id: space_without_booking.id,
        person: %{
          email: "new-email@gmail.com",
          first_name: "First name",
          last_name: "Last name"
        }
      }

      response = graphql_query(conn, %{query: query(), variables: variables}, :success)
      created_booking = Booking |> where(space_id: ^space_without_booking.id) |> Repo.one()
      assert response == %{"data" => %{
          "bookSpace" => %{ "id" => created_booking.id }
        }
      }
    end

    defp query() do
      """
      mutation bookSpace(
        $startAt: DateTime!
        $endAt: DateTime!
        $spaceId: UUID4!
        $person: BookSpacePersonInput!
      ) {
        bookSpace(
          startAt: $startAt
          endAt: $endAt
          spaceId: $spaceId
          person: $person
        ) {
          id
        }
      }
      """
    end
  end
end
