defmodule BloodbathWeb.Middleware.AuthorizedTeamMember do
  @behaviour Absinthe.Middleware

  def call(resolution = %{context: %{myself: %{ is_owner: _ }}}, _config) do
    resolution
  end

  def call(resolution, _config) do
    resolution
    |> Absinthe.Resolution.put_result({:error, not_authorized_error()})
  end

  defp not_authorized_error do
    %{message: "Not authorized, you're not a team member"}
  end
end
