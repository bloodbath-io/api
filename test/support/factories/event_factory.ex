defmodule Bloodbath.Factory.EventFactory do
  use ExMachina.Ecto, repo: Bloodbath.Repo
  alias Bloodbath.Factory.{
    PersonFactory,
  }

  def event_factory do
    person = PersonFactory.build(:person, is_owner: true)

    %Bloodbath.Core.Event{
      scheduled_for: Timex.shift(DateTime.utc_now(), days: 1, hours: 1),
      headers: "{}",
      payload: "{}",
      endpoint: "https://test.com/yes",
      person: person,
      origin: "graphql_api",
      status: "scheduled",
      organization: person.organization
    }
  end
end
