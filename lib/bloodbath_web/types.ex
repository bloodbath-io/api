defmodule Bloodbath.Schema.Types do
  use Absinthe.Schema.Notation

  object :connect_person do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :api_key, :string
    field :organization, :public_organization
    field :password_recovery_token, :string
  end

  object :public_person do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :organization, :public_organization
  end

  object :public_ping do
    field :received_at, :datetime
  end

  object :public_event do
    field :id, :uuid
    field :scheduled_for, :datetime
    field :payload, :string
    field :headers, :string
    field :endpoint, :string
    field :person, :public_person
    field :organization, :public_organization
  end

  object :public_organization do
    field :id, :uuid
    field :name, :string
    field :slug, :string
  end
end
