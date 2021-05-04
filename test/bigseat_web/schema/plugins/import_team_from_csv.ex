# defmodule BigseatWeb.Schema.ImportTeamFromCsvTest do
#   use BigseatWeb.ConnCase, async: true
#   alias Bigseat.Factory.{
#     PersonFactory,
#     SpaceFactory,
#     BookingFactory
#   }
#   use Bigseat.HelpersCase
#   alias Bigseat.Core.Booking

#   describe "import team from csv" do
#     setup do
#       [
#         myself: PersonFactory.insert(:person, is_admin: true),
#       ]
#     end

#     test "without authentication", %{conn: conn} do
#       response = graphql_query(conn, %{query: query(), variables: variables()}, :success)
#       assert Map.has_key?(response, "errors")
#     end

#     test "from a valid csv", %{
#       conn: conn,
#       person: person
#     } do
#       variables = %{
#       }

#       response = graphql_query(conn, %{query: query(), variables: variables}, :success)
#       created_booking = Booking |> where(space_id: ^space_without_booking.id) |> Repo.one()
#       assert response == %{"data" => %{
#           "bookSpace" => %{ "id" => created_booking.id }
#         }
#       }
#     end

#     defp query() do
#       """
#       mutation importTeamFromCsv(
#         $file: Upload!
#       ) {
#         importTeamFromCsv(
#           file: $file
#         ) {
#           id
#         }
#       }
#       """
#     end
#   end
# end
