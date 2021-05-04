defmodule Bigseat.Core.Organization do
  import Ecto.Query, only: [from: 2]
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    has_many :spaces, Bigseat.Core.Space
    has_many :people, Bigseat.Core.Person
    field :name, :string
    field :slug, :string

    timestamps()
  end

  def create_changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug])
    |> cast_assoc(:people)
    |> put_slug()
    |> validate_required([:name, :slug])
    |> unique_constraint(:slug)
  end

  def update_changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug])
    |> cast_assoc(:people)
    |> put_slug(%{ignore: organization.slug})
    |> unique_constraint(:slug)
  end

  defp put_slug(changeset, options \\ %{}) do
    case changeset.changes do
    %{slug: _} ->
      changeset
    _ ->
      put_change(changeset, :slug, Bigseat.Core.Organization.Helper.slug_with(changeset.changes, 0, options))
    end
  end
end

defmodule Bigseat.Core.Organization.Helper do
  import Ecto.Query, warn: false

  def slug_with(params = %{name: name}, iteration \\ 0, options = %{}) do
    raw_slug = Inflex.parameterize(name)
    end_slug = if iteration === 0 do
      raw_slug
    else
      "#{raw_slug}#{iteration}"
    end
    ignore = options[:ignore]
    query = from organization in Bigseat.Core.Organization, where: organization.slug == ^end_slug and organization.slug != ^ignore

    if Bigseat.Repo.exists?(query) do
      Bigseat.Core.Organization.Helper.slug_with(params, iteration+1, options)
    else
      end_slug
    end
  end
end
