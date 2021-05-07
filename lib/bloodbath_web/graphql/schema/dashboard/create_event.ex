defmodule Bloodbath.Schema.Dashboard.CreateEvent do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_create_event do
    @desc "Create a new event"
    field :create_event, :dashboard_event do
      arg :payload, non_null(:string)
      arg :headers, non_null(:string)
      arg :endpoint, non_null(:string)
      arg :scheduled_for, non_null(:datetime)

      middleware BloodbathWeb.Middleware.AuthorizedOwner
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, args, %{ context: %{ myself: myself }}) do
    parameters = Map.merge(args, %{origin: "graphql_api"})
    Bloodbath.Core.Events.create(myself, parameters)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
