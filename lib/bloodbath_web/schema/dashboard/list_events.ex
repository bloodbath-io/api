defmodule Bloodbath.Schema.Dashboard.ListEvents do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_list_events do
    @desc "Get a list of events"
    field :list_events, list_of(:dashboard_booking) do
      middleware BloodbathWeb.Middleware.AuthorizedAdmin
      resolve fn _parent, _args, _resolution ->
        {:ok, Bloodbath.Core.Events.list()}
      end
      middleware TranslateErrors
    end
  end
end
