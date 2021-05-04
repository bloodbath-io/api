defmodule Bigseat.Schema.Dashboard.AddNewTeamMember do
  use Absinthe.Schema.Notation
  alias Bigseat.Repo
  alias Bigseat.Core.Organization
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_add_new_team_member do
    @desc "Add a new team member to the organization"
    field :add_new_team_member, :dashboard_person do
      arg :first_name, non_null(:string)
      arg :last_name, non_null(:string)
      arg :email, non_null(:string)
      arg :group, non_null(:string)
      arg :origin, non_null(:string)

      middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, args, %{ context: %{ myself: %{ organization_id: organization_id }}}) do
    organization = Organization |> Repo.get(organization_id)
    Bigseat.Core.People.create_team_member(args, organization)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
