defmodule Bloodbath.Schema.Public.ListEvents do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :public_list_events do
    @desc "Get a list of events"
    field :list_events, list_of(:public_event) do
      middleware BloodbathWeb.Graphql.Middleware.AuthorizedOwner
      resolve fn _parent, _args, %{ context: %{ myself: myself }} ->
        {:ok, Bloodbath.Customer.Events.list(myself)}
      end
      middleware TranslateErrors
    end
  end
end
