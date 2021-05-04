defmodule Bigseat.Schema.Connect.Signin do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors
  import Comeonin.Bcrypt, only: [checkpw: 2]
  alias Bigseat.Repo
  alias Bigseat.Core.Person

  object :connect_signin do
    @desc "Signin to the dashboard"
    field :signin, :connect_person do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, %{ email: email, password: password }, _resolution) do
    person = Person |> Repo.get_by(email: String.downcase(email)) |> Repo.preload(:organization)

    cond do
      person && checkpw(password, person.encrypted_password) -> {:ok, person}
      person -> {:error, "Incorrect signin credentials"}
      true -> {:error, "Person not found"}
    end
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
