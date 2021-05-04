defmodule Bigseat.Factory.CheckinFactory do
  use ExMachina.Ecto, repo: Bigseat.Repo
  alias Bigseat.Factory.{
    PersonFactory,
    SpaceFactory
  }

  def checkin_factory do
    %Bigseat.Core.Checkin{
      checked_at: Timex.shift(DateTime.utc_now(), days: -1),
      person: PersonFactory.build(:person, is_admin: false),
      space: SpaceFactory.build(:space)
    }
  end
end
