defmodule Bloodbath.TrackingHandler.Events do
  alias Bloodbath.TrackingHandler.Services.{
    Mixpanel,
    Slack
  }

  defmacro dispatch(do: yield) do
    quote do
      if dispatch?() do
        unquote(yield)
      end
    end
  end

  def signup(person) do
    dispatch do
      Slack.send_message("New sign-up #{person.email}")
      Mixpanel.track_event(person.id, "Sign up")
      # Mixpanel.create_identity(person.id)
      Mixpanel.set_profile(person.id, person.last_known_ip, %{email: person.email, first_name: person.first_name, last_name: person.last_name})
    end
  end

  defp dispatch? do
    Mix.env() == :prod
  end
end
