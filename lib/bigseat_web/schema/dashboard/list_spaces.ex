defmodule Bigseat.Schema.Dashboard.ListSpaces do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_list_spaces do
    @desc "Get a list of spaces"
    field :list_spaces, list_of(:dashboard_space) do
      middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve fn _parent, _args, _resolution ->
        {:ok, Bigseat.Core.Spaces.list()}
      end
      middleware TranslateErrors
    end
  end
end
