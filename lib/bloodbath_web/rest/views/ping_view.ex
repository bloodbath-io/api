defmodule BloodbathWeb.PingView do
  use BloodbathWeb, :view
  alias BloodbathWeb.PingView

  def render("index.json", %{}) do
    %{
      received_at: Timex.now()
    }
  end
end
