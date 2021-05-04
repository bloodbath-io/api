defmodule BigseatWeb.Schema.ListSpacesFromBookingsTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory,
    SpaceFactory,
    BookingFactory
  }
  use Bigseat.HelpersCase

  describe "list_spaces_from_bookings" do
    setup do
      person = PersonFactory.insert(:person, is_admin: true)
      team_member = PersonFactory.insert(:person, is_admin: false)
      space = SpaceFactory.insert(:space, organization: person.organization)
      booking = BookingFactory.insert(:booking, space: space, person: team_member)
      space_without_booking = SpaceFactory.insert(:space, organization: person.organization)

      [
        organization: person.organization,
        space: space,
        space_without_booking: space_without_booking,
        booking: booking,
        person: person,
        team_member: team_member
      ]
    end

    test "with spaces with booking in this date range", %{
      conn: conn,
      space: space,
      organization: organization,
      booking: booking,
      space_without_booking: space_without_booking,
      team_member: team_member
    } do
      variables = %{
        start_at: booking.start_at |> Timex.shift(hours: -1) |> Timex.format!("{ISO:Extended}"),
        end_at: booking.start_at |> Timex.shift(hours: 1) |> Timex.format!("{ISO:Extended}"),
        organization_id: organization.id
      }

      response = graphql_query(conn, %{query: query(), variables: variables}, :success)
      assert response == %{"data" => %{
          "listSpacesFromBookings" => [
            %{
              "bookings" => [%{
                  "endAt" => booking.end_at |> Timex.format!("{ISO:Extended:Z}"),
                  "person" => %{"firstName" => team_member.first_name, "lastName" => team_member.last_name},
                  "startAt" => booking.start_at |> Timex.format!("{ISO:Extended:Z}")
                }],
              "id" => space.id,
              "maximumPeople" => 10,
              "name" => space.name
            },
            %{
              "bookings" => [],
              "id" => space_without_booking.id,
              "maximumPeople" => 10,
              "name" => space_without_booking.name
            }
          ]
        }
      }
    end

    defp query() do
      """
      query listSpacesFromBookings(
        $startAt: DateTime!
        $endAt: DateTime!
        $organizationId: UUID4!
      ) {
        listSpacesFromBookings(
          startAt: $startAt
          endAt: $endAt
          organizationId: $organizationId
        ) {
          id
          name
          maximumPeople
          bookings {
            startAt
            endAt
            person {
              firstName
              lastName
            }
          }
        }
      }
      """
    end
  end
end
