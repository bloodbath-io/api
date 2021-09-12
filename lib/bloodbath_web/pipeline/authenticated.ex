defmodule BloodbathWeb.Pipeline.Authenticated do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [where: 2]

  alias Bloodbath.Repo
  alias Bloodbath.AccountManagement.Person

  def init(opts), do: opts

  def call(conn, %{routing_origin: routing_origin}) do
    myself = case conn |> build_myself do
      {:ok, %{myself: myself}} -> myself
      _ -> nil
    end

    context = %{
      myself: myself,
      remote_ip: conn.remote_ip
    }

    conn |> insert(context, routing_origin)
  end

  defp insert(conn, context, routing_origin) do
    case routing_origin do
      :rest -> conn |> assign(:rest, %{context: context})
      :graphql -> conn |> put_private(:absinthe, %{context: context})
    end
  end

  defp build_myself(conn) do
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
      nil -> {:error, "Your API key isn't valid. Please read https://bloodbath.notion.site/Acquire-your-API-Key-3b4adbbcc7f948d0a5c52d165a963ae4 for more information"}
      person -> {:ok, person}
    end
  end
end
