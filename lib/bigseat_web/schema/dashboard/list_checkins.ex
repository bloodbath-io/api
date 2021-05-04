defmodule Bigseat.Schema.Dashboard.ListCheckins do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_list_checkins do
    @desc "Get a list of checkins"
    field :list_checkins, list_of(:dashboard_checkin) do
      middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve fn _parent, _args, _resolution ->
        {:ok, Bigseat.Core.Checkins.list()}
      end
      middleware TranslateErrors
    end
  end
end
