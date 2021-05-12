defmodule Bloodbath.Customer.Organization do
  import Ecto.Query, only: [from: 2]
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    has_many :events, Bloodbath.Customer.Event
    has_many :people, Bloodbath.Customer.Person
    field :name, :string
    field :slug, :string
    field :api_key, :string

    timestamps()
  end

  def create_changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug])
    |> cast_assoc(:people)
    |> put_api_key()
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
      put_change(changeset, :slug, Bloodbath.Customer.Organization.Helper.slug_with(changeset.changes, 0, options))
    end
  end

  defp put_api_key(changeset) do
    case Ecto.get_meta(changeset.data, :state) do
      :built ->
        api_key = :crypto.strong_rand_bytes(64) |> Base.url_encode64
        changeset |> put_change(:api_key, api_key)
      :loaded ->
        changeset
    end
  end
end

defmodule Bloodbath.Customer.Organization.Helper do
  import Ecto.Query, warn: false

  def slug_with(params = %{name: name}, iteration \\ 0, options = %{}) do
    raw_slug = Inflex.parameterize(name)
    end_slug = if iteration === 0 do
      raw_slug
    else
      "#{raw_slug}#{iteration}"
    end
    ignore = options[:ignore]

    query = if ignore do
      from organization in Bloodbath.Customer.Organization, where: organization.slug == ^end_slug and organization.slug != ^ignore
    else
      from organization in Bloodbath.Customer.Organization, where: organization.slug == ^end_slug
    end

    if Bloodbath.Repo.exists?(query) do
      Bloodbath.Customer.Organization.Helper.slug_with(params, iteration+1, options)
    else
      end_slug
    end
  end
end
