defmodule Bloodbath.Schema.Public.GetPing do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :public_get_ping do
    @desc "Get a ping"
    field :ping, :public_ping do
      middleware BloodbathWeb.Graphql.Middleware.AuthorizedOwner
      resolve fn _parent, _args, _resolution ->
        {:ok, %{received_at: Timex.now()}}
      end
      middleware TranslateErrors
    end
  end
end
