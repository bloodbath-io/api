defmodule Bloodbath.Schema.Dashboard.ListEvents do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_list_events do
    @desc "Get a list of events"
    field :list_events, list_of(:dashboard_event) do
      middleware BloodbathWeb.Middleware.AuthorizedOwner
      resolve fn _parent, _args, _resolution ->
        {:ok, Bloodbath.Core.Events.list()}
      end
      middleware TranslateErrors
    end
  end
end
