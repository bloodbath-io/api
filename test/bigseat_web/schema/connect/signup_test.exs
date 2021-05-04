defmodule BigseatWeb.Schema.SignupTest do
  use BigseatWeb.ConnCase, async: true
  use Bigseat.HelpersCase
  alias Bigseat.Core.{
    Person,
    Organization
  }

  describe "signup" do
    setup do
      [
        payload: %{
          email: "test@test.com",
          first_name: "Laurent",
          last_name: "Schaffner",
          organization: %{
            name: "BigSeat"
          },
          password: "Password0$"
        }
      ]
    end

    test "a new person", %{conn: conn, payload: payload} do
      mutation = payload |> valid_mutation
      response = conn |> graphql_query(%{query: mutation}, :success)
      person_created = Person |> first() |> Repo.one()

      assert response == %{"data" => %{"signup" => %{"id" => person_created.id}}}
    end

    test "a new person with a specific organization slug", %{conn: conn, payload: payload} do
      mutation = payload |> valid_mutation_with_slug("valid-slug")
      response = conn |> graphql_query(%{query: mutation}, :success)
      person_created = Person |> first() |> Repo.one()
      organization_created = Organization |> first() |> Repo.one()

      assert response == %{"data" => %{"signup" => %{"id" => person_created.id}}}
      assert organization_created.slug == "valid-slug"
    end

    defp valid_mutation(payload) do
      """
      mutation {
        signup(
          email: "#{payload.email}"
          firstName: "#{payload.first_name}"
          lastName: "#{payload.last_name}"
          organization: {
            name: "#{payload.organization.name}"
          }
          password: "#{payload.password}"
        ) {
          id
        }
      }
      """
    end

    defp valid_mutation_with_slug(payload, slug) do
      """
      mutation {
        signup(
          email: "#{payload.email}"
          firstName: "#{payload.first_name}"
          lastName: "#{payload.last_name}"
          organization: {
            name: "#{payload.organization.name}"
            slug: "#{slug}"
          }
          password: "#{payload.password}"
        ) {
          id
        }
      }
      """
    end
  end
end
