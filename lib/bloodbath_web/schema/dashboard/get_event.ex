defmodule Bloodbath.Schema.Dashboard.GetSpace do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_get_event do
    @desc "Get a specific event"
    field :get_event, :dashboard_event do
      arg :id, non_null(:uuid)

      middleware BloodbathWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{id: id}, _resolution) do
    {:ok, Bloodbath.Core.Events.get(id)}
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
