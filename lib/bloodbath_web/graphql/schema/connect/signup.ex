defmodule Bloodbath.GraphQL.Schema.Connect.Signup do
  use Absinthe.Schema.Notation
  alias Crudry.Middlewares.TranslateErrors

  object :connect_signup do
    @desc "Signup to the dashboard"
    field :signup, :connect_person do
      arg :first_name, non_null(:string)
      arg :last_name, non_null(:string)
      arg :email, non_null(:string)
      arg :password, non_null(:string)
      arg :organization, non_null(:organization_input)

      resolve &resolve/3
      middleware TranslateErrors
    end
  end

  input_object :organization_input do
    field :name, non_null(:string)
    field :slug, :string
  end

  def resolve(_parent, args, _resolution) do
    case Bloodbath.AccountManagement.People.create_owner(args) do
      {:ok, person} ->
        Bloodbath.TrackingHandler.Events.signup(person)
        {:ok, person}
      {:error, reason} -> {:error, reason}
    end
  end
end
