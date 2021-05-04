defmodule BigseatWeb.Middleware.AuthorizedAdmin do
  @behaviour Absinthe.Middleware

  def call(resolution = %{context: %{myself: %{ is_admin: true }}}, _config) do
    resolution
  end

  def call(resolution, _config) do
    resolution
    |> Absinthe.Resolution.put_result({:error, not_authorized_error()})
  end

  defp not_authorized_error do
    %{message: "Not authorized, you're not an admin"}
  end
end
