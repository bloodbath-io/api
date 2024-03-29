defmodule Bloodbath.AccountManagement.Organizations do

  import Ecto.Query, warn: false
  alias Bloodbath.Repo
  alias Bloodbath.AccountManagement.Organization

  def list, do: Repo.all(Organization)
  def get(id), do: Repo.get(Organization, id)

  def create(attrs \\ %{}) do
    %Organization{}
    |> Organization.create_changeset(attrs)
    |> Repo.insert()
  end

  def update(%Organization{} = organization, attrs) do
    organization
    |> Organization.update_changeset(attrs)
    |> Repo.update()
  end

  def delete(%Organization{} = organization) do
    Repo.delete(organization)
  end
end
