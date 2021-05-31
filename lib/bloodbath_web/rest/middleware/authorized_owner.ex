defmodule BloodbathWeb.Rest.Middleware.AuthorizedOwner do
  import Plug.Conn

  def init(config), do: config

  def call(conn, _config) do
    case conn.assigns do
      %{ rest: %{ context: %{ myself: %{ is_owner: true }}}} ->
        conn
      _ ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{errors: ["Your API key isn't valid. Please read https://docs.bloodbath.io/Acquire-your-API-Key-3b4adbbcc7f948d0a5c52d165a963ae4 for more information"]})
        |> halt
    end
  end
end
