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
        |> Phoenix.Controller.json(%{errors: ["Unauthorized. Your API key isn't valid."]})
        |> halt
    end
  end
end
