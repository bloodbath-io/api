# the following thing will create the root node query
# which's a practical way to get any record from any type
# see https://dev.to/zth/the-magic-of-the-node-interface-4le1
# for more information
defmodule Bloodbath.GraphQL.Schema.Public.Node do
  defmacro __using__(_) do
    quote do
      middleware BloodbathWeb.Graphql.Middleware.AuthorizedOwner

      resolve fn
        %{type: :event, id: id}, %{ context: %{ myself: myself } } ->
          {:ok, Bloodbath.CustomerEventsManagement.Events.find(myself, id)}
      end
    end
  end
end
