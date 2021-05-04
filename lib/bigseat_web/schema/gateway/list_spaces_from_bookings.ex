defmodule Bigseat.Schema.Gateway.ListSpacesFromBookings do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors
  alias Bigseat.Repo
  alias Bigseat.Core.Organization

  object :gateway_list_spaces_from_bookings do
    @desc "List spaces by date range and its bookings"
    field :list_spaces_from_bookings, list_of(:gateway_space) do
      arg :organization_id, non_null(:uuid)
      arg :start_at, non_null(:datetime)
      arg :end_at, non_null(:datetime)

      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{ start_at: start_at, end_at: end_at, organization_id: organization_id }, _resolution) do
    organization = Organization |> Repo.get(organization_id)
    case organization do
      %Organization{} -> {:ok, Bigseat.Core.Spaces.list_with_bookings(organization, start_at, end_at)}
      _ -> {:error, "organization not found"}
    end
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
