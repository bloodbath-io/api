defmodule Bloodbath.Customer.People do
  import Ecto.Query, warn: false
  alias Bloodbath.Repo
  alias Ecto.Multi

  alias Bloodbath.Customer.{
    Person,
    Organization
  }

  def list do
    Person |> Repo.all
  end

  def get(id) do
    Person |> Repo.get(id)
  end

  def create_owner(params = %{ organization: organization_params } \\ %{}) do
    organization_changeset = %Organization{}
    |> Organization.create_changeset(organization_params)

    # those are default attributes
    # when you create from scratch
    person_characteristics = %{
      is_owner: true,
      type: "TeamMember",
      origin: "native"
    }

    multi = Multi.new
    |> Multi.insert(:organization, organization_changeset)
    |> Multi.run(:person, fn _repo, %{organization: organization} ->
      %Person{}
      |> Person.create_changeset(Map.merge(person_characteristics, Map.delete(params, :organization)))
      |> Ecto.Changeset.put_assoc(:organization, organization)
      |> Repo.insert()
    end)

    case Repo.transaction(multi) do
      {:ok, %{person: person}} -> {:ok, person}
      {:error, _model, changeset, _changes_so_far} -> {:error, changeset}
    end
  end

  def create_team_member(params \\ %{}, %Organization{} = organization) do
    person_characteristics = %{
      is_owner: false,
      type: "TeamMember"
    }

    %Person{}
    |> Person.create_changeset(Map.merge(person_characteristics, params))
    |> Ecto.Changeset.put_assoc(:organization, organization)
    |> Repo.insert()
  end

  def update(%Person{} = person, params) do
    person
    |> Person.update_changeset(params)
    |> Repo.update()
  end

  def delete(%Person{} = person) do
    person |> Repo.delete()
  end
end
