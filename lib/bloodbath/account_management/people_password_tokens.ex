defmodule Bloodbath.AccountManagement.PeoplePasswordTokens do
  import Ecto.Query, warn: false
  alias Bloodbath.Mailer
  alias Bloodbath.Repo

  alias Bloodbath.AccountManagement.{
    Person,
    PeoplePasswordToken
  }

  def request_new_password_by_email(email) do
    person = Person |> where(email: ^email) |> Repo.one()
    case person do
      %Person{} ->
        {:ok, %{token: token}} = %PeoplePasswordToken{}
        |> PeoplePasswordToken.changeset(%{})
        |> Ecto.Changeset.put_assoc(:person, person)
        |> Repo.insert()
        Bloodbath.AccountManagement.Emails.request_new_password(email, token)
        |> Mailer.deliver_now()
        {:ok, person}
      _ ->
        {:ok, %Person{email: email}}
    end
  end

  def confirm_new_password(token, new_password) do
    people_password_token = PeoplePasswordToken |> Repo.get_by(token: token) |> Repo.preload(:person)
    case people_password_token do
      %PeoplePasswordToken{} ->
        person = people_password_token.person
        person |> Person.update_changeset(%{password: new_password})
        people_password_token |> Repo.delete()
        {:ok, person}
      _ ->
        {:error, "token not found"}
    end
  end
end
