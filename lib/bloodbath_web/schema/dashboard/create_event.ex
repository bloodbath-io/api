defmodule Bloodbath.Schema.Dashboard.CreateEvent do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_create_event do
    @desc "Create a new event"
    field :create_event, :dashboard_event do
      arg :payload, non_null(:string)
      arg :headers, non_null(:string)
      arg :endpoint, non_null(:string)
      arg :start_at, non_null(:datetime)

      middleware BloodbathWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, args, %{ context: %{ myself: myself }}) do
    Bloodbath.Core.Events.create(myself, args)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
