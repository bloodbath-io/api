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
    %{message: "Unauthorized. Your API key isn't valid."}
  end
end
