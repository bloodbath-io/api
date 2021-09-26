defmodule Bloodbath.GraphQL.Schema.Public.ListEvents do
  defmacro __using__([]) do
    quote do
      connection field :list_events, node_type: :public_event do
        middleware BloodbathWeb.Graphql.Middleware.AuthorizedOwner

        resolve fn arguments, %{ context: %{ myself: myself }} ->
          Absinthe.Relay.Connection.from_query(
            Bloodbath.CustomerEventsManagement.Events.list_query(myself, arguments),
            &Bloodbath.Repo.all/1,
            arguments
          )
        end
      end
    end
  end
end
