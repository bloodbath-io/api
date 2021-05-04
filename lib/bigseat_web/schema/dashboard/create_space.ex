defmodule Bigseat.Schema.Dashboard.CreateSpace do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_create_space do
    @desc "Create a new space"
    field :create_space, :dashboard_space do
      arg :avatar, :upload
      arg :slug, :string
      arg :name, non_null(:string)
      arg :open_hours, list_of(non_null(:open_hours_input))
      arg :maximum_people, non_null(:integer)
      arg :daily_checkin, non_null(:boolean)

      middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  input_object :open_hours_input do
    field :day_of_the_week, non_null(:string)
    field :open_time, non_null(:time) # ISO 8601
    field :close_time, non_null(:time) # ISO 8601
  end

  def resolve(_parent, args, %{ context: %{ myself: %{ organization_id: organization_id} }}) do
    Bigseat.Core.Spaces.create(args, organization_id)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
