defmodule Bigseat.Schema.Dashboard.EditMyOrganization do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors
  alias Bigseat.Repo

  object :dashboard_edit_my_organization do
    @desc "Edit my organization"
    field :edit_my_organization, :dashboard_organization do
      arg :name, :string

      middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, args, %{ context: %{ myself: myself }}) do
    with_organization = myself |> Repo.preload(:organization)
    Bigseat.Core.Organizations.update(with_organization.organization, args)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
