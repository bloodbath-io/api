defmodule Bigseat.Schema.Dashboard.ListBookings do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_list_bookings do
    @desc "Get a list of bookings"
    field :list_bookings, list_of(:dashboard_booking) do
      middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve fn _parent, _args, _resolution ->
        {:ok, Bigseat.Core.Bookings.list()}
      end
      middleware TranslateErrors
    end
  end
end
