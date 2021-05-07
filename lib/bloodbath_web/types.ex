defmodule Bloodbath.Schema.Types do
  use Absinthe.Schema.Notation

  object :connect_person do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :access_token, :string
    field :organization, :dashboard_organization
    field :password_recovery_token, :string
  end

  object :dashboard_person do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :organization, :dashboard_organization
  end

  object :dashboard_event do
    field :id, :uuid
    field :scheduled_for, :datetime
    field :payload, :string
    field :headers, :string
    field :endpoint, :string
    field :person, :dashboard_person
    field :organization, :dashboard_organization
  end

  object :dashboard_organization do
    field :id, :uuid
    field :name, :string
    field :slug, :string
  end
end
