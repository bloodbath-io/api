defmodule BloodbathWeb.Pipeline.Authenticated do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [where: 2]

  alias Bloodbath.Repo
  alias Bloodbath.Core.Person

  def init(opts), do: opts

  def call(conn, %{routing_origin: routing_origin}) do
   case build_context(conn) do
    {:ok, context} -> conn |> insert(context, routing_origin)
    _ -> conn
   end
  end

  defp insert(conn, context, routing_origin) do
    case routing_origin do
      :rest -> conn |> assign(:rest, %{context: context})
      :graphql -> conn |> put_private(:absinthe, %{context: context})
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
