defmodule Bloodbath.Core.Person do
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "people" do
    belongs_to :organization, Bloodbath.Core.Organization
    has_many :events, Bloodbath.Core.Event
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :first_name, :string
    field :group, Ecto.Enum, values: [:remote, :office]
    field :type, :string
    field :origin, :string
    field :is_admin, :boolean, default: false
    field :last_name, :string
    field :access_token, :string

    timestamps()
  end

  def create_changeset(person, attrs) do
    person
    |> cast(attrs, [:email, :password, :first_name, :last_name, :is_admin, :type, :group, :origin, :access_token])
    |> cast_assoc(:organization)
    |> put_access_token()
    |> validate_required([:email, :first_name, :last_name, :access_token, :type, :group, :origin])
    |> unique_constraint(:email, name: :people_organization_id_email_index)
    |> validate_unique_admin()
    |> put_encrypted_password()
  end

  def update_changeset(person, attrs) do
    person
    |> cast(attrs, [:email, :password, :first_name, :last_name, :group])
    |> unique_constraint(:email, name: :people_organization_id_email_index)
    |> put_encrypted_password()
  end

  defp validate_unique_admin(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{is_admin: true}} ->
        email = Map.get(changeset.changes, :email)
        query = from person in Bloodbath.Core.Person, where: person.email == ^email, where: person.is_admin == true

        case Bloodbath.Repo.exists?(query) == false do
          true -> changeset
          false -> add_error(changeset, :email, "already in use within another organization")
        end
      _ ->
        changeset
    end
  end

  defp put_encrypted_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        changeset
    end
  end

  defp put_access_token(changeset) do
    case Ecto.get_meta(changeset.data, :state) do
      :built ->
        access_token = :crypto.strong_rand_bytes(64) |> Base.url_encode64
        changeset |> put_change(:access_token, access_token)
      :loaded ->
        changeset
    end
  end
end
