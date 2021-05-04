defmodule BloodbathWeb.Pipeline.Authenticated do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [where: 2]

  alias Bloodbath.Repo
  alias Bloodbath.Core.Person

  def init(opts), do: opts

  def call(conn, _) do
   case build_context(conn) do
    {:ok, context} -> put_private(conn, :absinthe, %{context: context})
    _ -> conn
   end
  end

  defp build_context(conn) do
    with ["Bearer " <> access_token] <- get_req_header(conn, "authorization"),
        {:ok, myself} <- authorize(access_token) do
        {:ok, %{myself: myself}}
    end
  end

  defp authorize(access_token) do
    Person
    |> where(access_token: ^access_token)
    |> Repo.one()
    |> case do
      nil -> {:error, "Invalid api key"}
      person -> {:ok, person}
    end
  end
end
