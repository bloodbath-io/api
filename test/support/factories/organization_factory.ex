defmodule Bloodbath.Factory.OrganizationFactory do
  use ExMachina.Ecto, repo: Bloodbath.Repo

  def organization_factory do
    name = Faker.Pokemon.location()
    %Bloodbath.Core.Organization{
      name: name,
      slug: Inflex.parameterize(name)
    }
  end
end
