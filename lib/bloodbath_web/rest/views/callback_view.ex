defmodule BloodbathWeb.CallbackView do
  use BloodbathWeb, :view
  alias BloodbathWeb.CallbackView

  def render("index.json", %{}) do
    %{
      received_at: Timex.now()
    }
  end
end
