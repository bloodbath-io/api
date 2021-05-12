defmodule Bloodbath.Schema.Public.RemoveEvent do
  import Ecto.Query, warn: false
  use Absinthe.Schema.Notation
  alias Bloodbath.Repo
  alias Crudry.Middlewares.TranslateErrors
  alias Bloodbath.Customer.Event

  object :public_remove_event do
    @desc "Remove an event from the organization"
    field :remove_event, :public_event do
      arg :id, non_null(:uuid)

      middleware BloodbathWeb.Graphql.Middleware.AuthorizedOwner
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{ id: id }, %{ context: %{ myself: myself }}) do
    Bloodbath.Customer.Events.delete(myself, id)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
