defmodule BloodbathWeb.Router do
  use BloodbathWeb, :router

  pipeline :graphql do
    plug CORSPlug, origin: "*"
  end

  pipeline :rest do
    plug :accepts, ["json"]
  end

  pipeline :rest_authenticated do
    plug BloodbathWeb.Pipeline.Authenticated, %{routing_origin: :rest}
  end

  pipeline :graphql_authenticated do
    plug BloodbathWeb.Pipeline.Authenticated, %{routing_origin: :graphql}
  end

  pipeline :rest_authorized_owner do
    plug BloodbathWeb.Rest.Middleware.AuthorizedOwner
  end

  scope "/rest", BloodbathWeb do
    pipe_through :rest
    pipe_through :rest_authenticated
    pipe_through :rest_authorized_owner
    resources "/events", EventController, except: [:new, :edit, :update]
    get "/ping", PingController, :index
  end

  scope "/" do
    pipe_through :graphql
    pipe_through :graphql_authenticated

    # we limit the access to the
    # full introspection to dev only
    # for this schema
    if Mix.env == :dev do
      get "/graphql/full", Absinthe.Plug.GraphiQL, schema: Bloodbath.GraphQL.Schema
    end

    post "/graphql/full", Absinthe.Plug.GraphiQL, schema: Bloodbath.GraphQL.Schema

    # this will be the public schema
    # it can be accessed in production too
    get "/graphql", Absinthe.Plug.GraphiQL, schema: Bloodbath.GraphQL.PublicSchema
    post "/graphql", Absinthe.Plug.GraphiQL, schema: Bloodbath.GraphQL.PublicSchema
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BloodbathWeb.Telemetry
    end
  end
end
