defmodule Bloodbath.Factory.EventFactory do
  use ExMachina.Ecto, repo: Bloodbath.Repo
  alias Bloodbath.Factory.{
    PersonFactory,
  }

  def event_factory do
    person = PersonFactory.build(:person, is_admin: false)

    %Bloodbath.Core.Event{
      start_at: Timex.shift(DateTime.utc_now(), days: 1, hours: 1),
      person: person,
      organization: person.organization
    }
  end
end
