defmodule BloodbathWeb.Graphql.Middleware.AuthorizedAny do
  @behaviour Absinthe.Middleware

  def call(resolution = %{context: %{myself: _}}, _config) do
    resolution
  end

  def call(resolution, _config) do
    resolution
    |> Absinthe.Resolution.put_result({:error, not_authorized_error()})
  end

  defp not_authorized_error do
    %{message: "Unauthorized. You're not signed-in"}
  end
end
