defmodule BigseatWeb.Schema.EditPersonTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory
  }
  use Bigseat.HelpersCase

  describe "get_person" do
    setup do
      myself = PersonFactory.insert(:person, is_admin: true)

      [
        person: PersonFactory.insert(:person, organization: myself.organization),
        myself: myself,
      ]
    end

    test "without authentication", %{conn: conn, person: person} do
      response = graphql_query(conn, %{query: query(), variables: person |> variables(%{firstName: "Random name"})}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, myself: myself, person: person} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: person |> variables(%{firstName: "Random name"})}, :success)
      assert response == %{"data" => %{"editPerson" => %{"id" => "#{person.id}", "firstName" => "Random name"}}}
    end

    defp query() do
      """
      mutation editPerson(
        $id: UUID4
        $personInput: PersonInput!
      ) {
        editPerson(
          id: $id
          personInput: $personInput
        ) {
          id
          firstName
        }
      }
      """
    end

    def variables(person, person_input) do
      %{
        id: person.id,
        person_input: person_input
      }
    end
  end
end
