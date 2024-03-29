defmodule Bloodbath.GraphQL.Schema.Public.ScheduleEvent do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :public_schedule_event do
    @desc "Create a new event"
    field :schedule_event, :public_event do
      arg :body, :string
      arg :headers, non_null(:string)
      arg :method, non_null(:string)
      arg :endpoint, non_null(:string)
      arg :scheduled_for, non_null(:datetime)

      middleware BloodbathWeb.Graphql.Middleware.AuthorizedOwner
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, args, %{ context: %{ myself: myself }}) do
    parameters = Map.merge(args, %{origin: :graphql_api})
    Bloodbath.CustomerEventsManagement.Events.schedule(myself, parameters)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
