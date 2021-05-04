defmodule Bigseat.Factory.OrganizationFactory do
  use ExMachina.Ecto, repo: Bigseat.Repo

  def organization_factory do
    name = Faker.Pokemon.location()
    %Bigseat.Core.Organization{
      name: name,
      slug: Inflex.parameterize(name)
    }
  end
end
