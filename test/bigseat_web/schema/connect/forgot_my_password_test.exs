defmodule BigseatWeb.Schema.ForgotMyPasswordTest do
  use BigseatWeb.ConnCase, async: true
  alias Bigseat.Factory.PersonFactory
  use Bigseat.HelpersCase

  describe "forgot_my_password" do
    setup do
      [
        person: PersonFactory.insert(:person, is_admin: true, email: "existing-email@gmail.com"),
      ]
    end

    test "with existing email", %{conn: conn, person: person} do
      response = conn |> graphql_query(%{query: query(), variables: %{email: person.email}}, :success)
      assert response == %{"data" => %{"forgotMyPassword" => %{"email" => person.email}}}
    end

    test "with non existing email", %{conn: conn} do
      response = conn |> graphql_query(%{query: query(), variables: %{email: "wrong-email@gmail.com"}}, :success)
      assert response == %{"data" => %{"forgotMyPassword" => %{"email" => "wrong-email@gmail.com"}}}
    end

    defp query() do
      """
      mutation forgotMyPassword(
        $email: String!
      ) {
        forgotMyPassword(
          email: $email
        ) {
          email
        }
      }
      """
    end

    def variables() do
      %{
        email: "existing@email.com",
      }
    end
  end
end
