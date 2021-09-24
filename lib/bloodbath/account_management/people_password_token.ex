defmodule Bloodbath.AccountManagement.PeoplePasswordToken do
  import Ecto.Query, warn: false
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  @foreign_key_type Ecto.UUID
  schema "people_password_tokens" do
    belongs_to :person, Bloodbath.AccountManagement.Person
    field :token, :string

    timestamps()
  end

  def changeset(people_password_token, attrs) do
    people_password_token
    |> cast(attrs, [])
    |> put_token()
  end

  defp put_token(changeset) do
    token = :crypto.strong_rand_bytes(64) |> Base.url_encode64
    put_change(changeset, :token, token)
  end
end
