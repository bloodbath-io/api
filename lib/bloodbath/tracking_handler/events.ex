defmodule Bloodbath.TrackingHandler.Events do
  alias Bloodbath.TrackingHandler.Services.Mixpanel
  def signup(person) do
    Mixpanel.track_event(person.id, "Sign up")
    # Mixpanel.create_identity(person.id)
    Mixpanel.set_profile(person.id, %{email: person.email, first_name: person.first_name, last_name: person.last_name})
  end
end
