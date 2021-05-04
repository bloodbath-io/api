defmodule Bigseat.Factory.BookingFactory do
  use ExMachina.Ecto, repo: Bigseat.Repo
  alias Bigseat.Factory.{
    PersonFactory,
    SpaceFactory
  }

  def booking_factory do
    %Bigseat.Core.Booking{
      start_at: Timex.shift(DateTime.utc_now(), days: -1),
      end_at: Timex.shift(DateTime.utc_now(), days: 1, hours: 1),
      person: PersonFactory.build(:person, is_admin: false),
      space: SpaceFactory.build(:space)
    }
  end
end
