defmodule Bloodbath.GraphQL.Schema.Types do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  # the node interface is at the root of the query type
  # it's something provided by relay
  # each model we want to use with relay should have
  # its line in there to source the node
  # this call should be declared before any `node object` one
  node interface do
    resolve_type fn
      %Bloodbath.CustomerEventsManagement.Event{}, _ -> :public_event
      _, _ -> nil
    end
  end

  object :connect_person do
    field :id, :uuid
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :password, :string
    field :api_key, :string
    field :organization, :public_organization
    field :password_recovery_token, :string
    field :inserted_at, :datetime
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

  node object :public_event do
    # we output the event id because the id
    # will be the one from the node
    field :event_id, :string, resolve: fn _arguments, resource ->
      {:ok, resource.source.id}
    end
    field :scheduled_for, :datetime
    field :dispatched_at, :datetime
    field :locked_at, :datetime
    field :enqueued_at, :datetime
    field :body, :string
    field :headers, :string
    field :endpoint, :string
    field :method, :string
    field :person, :public_person
    field :organization, :public_organization
    field :inserted_at, :datetime
    field :updated_at, :datetime
  end

  object :public_organization do
    field :id, :uuid
    field :name, :string
    field :slug, :string
  end
end
