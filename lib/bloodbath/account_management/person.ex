defmodule Bloodbath.AccountManagement.Person do
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "people" do
    belongs_to :organization, Bloodbath.AccountManagement.Organization
    has_many :events, Bloodbath.CustomerEventsManagement.Event
    field :email, :string
    field :password, :string, virtual: true
    field :encrypted_password, :string
    field :first_name, :string
    field :type, :string
    field :origin, :string
    field :is_owner, :boolean, default: false
    field :last_name, :string
    field :api_key, :string
    field :last_known_ip, :string

    timestamps([type: :utc_datetime_usec])
  end

  def create_changeset(person, attrs) do
    person
    |> cast(attrs, [:email, :password, :first_name, :last_name, :is_owner, :type, :origin, :api_key, :last_known_ip])
    |> cast_assoc(:organization)
    |> put_api_key()
    |> validate_required([:email, :first_name, :last_name, :api_key, :type, :origin, :last_known_ip])
    |> unique_constraint(:email, name: :people_organization_id_email_index)
    |> validate_unique_admin()
    |> put_encrypted_password()
  end

  def update_changeset(person, attrs) do
    person
    |> cast(attrs, [:email, :password, :first_name, :last_name])
    |> unique_constraint(:email, name: :people_organization_id_email_index)
    |> put_encrypted_password()
  end

  defp validate_unique_admin(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{is_owner: true}} ->
        email = Map.get(changeset.changes, :email)
        query = from person in Bloodbath.AccountManagement.Person, where: person.email == ^email, where: person.is_owner == true

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
