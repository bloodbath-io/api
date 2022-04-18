defmodule BloodbathWeb.CallbackController do
  use BloodbathWeb, :controller

  action_fallback BloodbathWeb.FallbackController

  def create(conn, params) do
    render(conn, "index.json")
  end
end
