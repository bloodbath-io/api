defmodule Bigseat.Schema.Dashboard.EditMyAccount do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :dashboard_edit_my_account do
    @desc "Edit my account"
    field :edit_my_account, :dashboard_person do
      arg :first_name, :string
      arg :last_name, :string
      arg :email, :string
      arg :password, :string

      middleware BigseatWeb.Middleware.AuthorizedAdmin
      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  def resolve(_parent, args, %{ context: %{ myself: myself }}) do
    Bigseat.Core.People.update(myself, args)
  end

  def resolve(_parent, _args, _resolution) do
    {:error, "not found"}
  end
end
