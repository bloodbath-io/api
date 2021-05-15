defmodule Bloodbath.GraphQL.Schema.Public.GetEvent do
  import Ecto.Query, warn: false
  use Absinthe.Schema.Notation
  alias Bloodbath.Repo
  alias Crudry.Middlewares.TranslateErrors
  alias Bloodbath.CustomerEventsManagement.Event

  object :public_get_event do
    @desc "Get a specific event"
    field :get_event, :public_event do
      arg :id, non_null(:uuid)

      middleware BloodbathWeb.Graphql.Middleware.AuthorizedOwner
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{id: id}, %{ context: %{ myself: myself }}) do
    {:ok, Bloodbath.CustomerEventsManagement.Events.get(myself, id)}
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
