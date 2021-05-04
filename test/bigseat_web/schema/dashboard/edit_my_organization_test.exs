defmodule BigseatWeb.Schema.EditMyOrganizationTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.{
    PersonFactory,
    OrganizationFactory
  }
  use Bigseat.HelpersCase

  describe "edit_my_organization" do
    setup do
      organization = OrganizationFactory.insert(:organization)

      [
        organization: organization,
        myself: PersonFactory.insert(:person, is_admin: true, organization: organization),
      ]
    end

    test "without authentication", %{conn: conn} do
      response = graphql_query(conn, %{query: query(), variables: variables()}, :success)
      assert Map.has_key?(response, "errors")
    end

    test "with authentication", %{conn: conn, myself: myself, organization: organization} do
      auth_conn = conn |> authorize(myself)

      response = graphql_query(auth_conn, %{query: query(), variables: variables()}, :success)
      assert response == %{"data" => %{"editMyOrganization" => %{"id" => organization.id, "name" => "New name"}}}
    end

    defp query() do
      """
      mutation editMyOrganization(
        $name: String
      ) {
        editMyOrganization(
          name: $name
        ) {
          id
          name
        }
      }
      """
    end

    def variables() do
      %{
        name: "New name"
      }
    end
  end
end
