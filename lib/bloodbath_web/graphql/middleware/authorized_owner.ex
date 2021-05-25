defmodule BloodbathWeb.Graphql.Middleware.AuthorizedOwner do
  @behaviour Absinthe.Middleware

  def call(resolution = %{context: %{myself: %{ is_owner: true }}}, _config) do
    resolution
  end

  def call(resolution, _config) do
    resolution
    |> Absinthe.Resolution.put_result({:error, not_authorized_error()})
  end

  defp not_authorized_error do
    %{message: "Your API key isn't valid. Please read https://www.notion.so/Acquire-your-API-Key-3b4adbbcc7f948d0a5c52d165a963ae4 for more information"}
  end
end
