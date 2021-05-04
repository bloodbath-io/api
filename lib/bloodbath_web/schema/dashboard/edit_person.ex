defmodule Bloodbath.Schema.Dashboard.EditPerson do
  import Ecto.Query, warn: false
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors
  alias Bloodbath.Core.Person
  alias Bloodbath.Repo

  object :dashboard_edit_person do
    @desc "Edit a specific person"
    field :edit_person, :dashboard_person do
      arg :id, :uuid
      arg :person_input, non_null(:person_input)

      middleware BloodbathWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  input_object :person_input do
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :group, :string
  end

  def resolve(_parent, %{ id: id, person_input: person_input }, %{ context: %{ myself: %{ organization_id: organization_id }}}) do
    person = Person |> where(id: ^id) |> where(organization_id: ^organization_id) |> Repo.one()
    case person do
      %Person{} -> Bloodbath.Core.People.update(person, person_input)
      _ -> {:error, "person not found"}
    end
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
