defmodule Bloodbath.Factory.OrganizationFactory do
  use ExMachina.Ecto, repo: Bloodbath.Repo

  def organization_factory do
    name = Faker.Pokemon.location()

    %Bloodbath.Customer.Organization{
      name: name,
      slug: Inflex.parameterize(name),
      api_key: :crypto.strong_rand_bytes(64) |> Base.url_encode64,
    }
  end
end
