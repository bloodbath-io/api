defmodule Bloodbath.Schema.Public.EditMyAccount do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :public_edit_my_account do
    @desc "Edit my account"
    field :edit_my_account, :public_person do
      arg :first_name, :string
      arg :last_name, :string
      arg :email, :string
      arg :password, :string

      middleware BloodbathWeb.Graphql.Middleware.AuthorizedOwner
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, args, %{ context: %{ myself: myself }}) do
    Bloodbath.AccountManagement.People.update(myself, args)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
