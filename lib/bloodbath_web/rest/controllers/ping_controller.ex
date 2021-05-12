defmodule BloodbathWeb.PingController do
  use BloodbathWeb, :controller

  action_fallback BloodbathWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.json")
  end
end
