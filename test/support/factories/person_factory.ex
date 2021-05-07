defmodule Bloodbath.Factory.PersonFactory do
  use ExMachina.Ecto, repo: Bloodbath.Repo
  alias Bloodbath.Factory.OrganizationFactory

  def person_factory do
    %Bloodbath.Core.Person{
      organization: OrganizationFactory.build(:organization),
      email: Faker.Internet.email(),
      first_name: Faker.Person.first_name(),
      last_name: Faker.Person.last_name(),
      origin: "native",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("password"),
      access_token: :crypto.strong_rand_bytes(64) |> Base.url_encode64,
      type: "TeamMember"
    }
  end

  def people_password_token_factory do
    %Bloodbath.Core.PeoplePasswordToken{
      person: build(:person),
      token: "random-token"
    }
  end
end