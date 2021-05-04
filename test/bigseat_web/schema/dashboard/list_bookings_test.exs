defmodule BigseatWeb.Schema.ListBookingsTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory,
    SpaceFactory,
    OrganizationFactory,
    BookingFactory
  }
  use Bigseat.HelpersCase

  describe "list bookings" do
    setup do
      organization = OrganizationFactory.insert(:organization)
      myself = PersonFactory.insert(:person, is_admin: true, organization: organization)
      team_member = PersonFactory.insert(:person, is_admin: false, organization: organization)
      space = SpaceFactory.insert(:space, organization: organization)
      booking = BookingFactory.insert(:booking, person: team_member, space: space)

      [
        booking: booking,
        myself: myself,
        team_member: team_member,
        space: space
      ]
    end

    test "get list of bookings without authentication", %{conn: conn} do
      response = graphql_query(conn, %{query: query()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "gets a booking by id", %{conn: conn, booking: booking, space: space, myself: myself, team_member: team_member} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query()}, :success)
      assert response == %{
        "data" => %{
          "listBookings" =>
          [
            %{"id" => "#{booking.id}", "person" => %{"id" => team_member.id}, "space" => %{"id" => space.id}}
          ]
        }
      }
    end


    defp query do
      """
      query listBookings {
        listBookings {
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
