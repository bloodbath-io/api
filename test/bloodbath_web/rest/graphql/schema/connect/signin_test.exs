defmodule BloodbathWeb.Schema.SigninTest do
  use BloodbathWeb.ConnCase, async: true
  alias Bloodbath.Factory.PersonFactory
  use Bloodbath.HelpersCase

  describe "signin" do
    setup do
      [
        person: PersonFactory.insert(:person, %{email: "test@test.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("Password0$")}),
        payload: %{
          email: "test@test.com",
          password: "Password0$"
        }
      ]
    end

    test "a new person", %{conn: conn, payload: payload, person: person} do
      mutation = payload |> valid_mutation
      response = conn |> graphql_query(%{query: mutation}, :success)

      assert response == %{"data" =>
        %{"signin" =>
          %{
            "id" => person.id,
            "access_token" => person.access_token
          }
        }
      }
    end

    defp valid_mutation(payload) do
      """
      mutation {
        signin(
          email: "#{payload.email}"
          password: "#{payload.password}"
        ) {
          id
          access_token
        }
      }
      """
    end
  end
end
