defmodule Bigseat.Schema.Dashboard.GetSpace do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_get_space do
    @desc "Get a specific space"
    field :get_space, :dashboard_space do
      arg :id, non_null(:uuid)

      middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{id: id}, _resolution) do
    {:ok, Bigseat.Core.Spaces.get(id)}
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
