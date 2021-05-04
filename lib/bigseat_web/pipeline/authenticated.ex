defmodule BigseatWeb.Pipeline.Authenticated do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [where: 2]

  alias Bigseat.Repo
  alias Bigseat.Core.Person

  def init(opts), do: opts

  def call(conn, _) do
   case build_context(conn) do
    {:ok, context} -> put_private(conn, :absinthe, %{context: context})
    _ -> conn
   end
  end

  defp build_context(conn) do
    with ["Bearer " <> api_key] <- get_req_header(conn, "authorization"),
        {:ok, myself} <- authorize(api_key) do
        {:ok, %{myself: myself}}
    end
  end

  defp authorize(api_key) do
    Person
    |> where(api_key: ^api_key)
    |> Repo.one()
    |> case do
      nil -> {:error, "Invalid api key"}
      person -> {:ok, person}
    end
  end
end
