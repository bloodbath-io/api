defmodule BloodbathWeb.Router do
  use BloodbathWeb, :router

  pipeline :graphql do
    plug CORSPlug
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
  end

  scope "/" do
    pipe_through :graphql
    pipe_through :graphql_authenticated
    forward "/graphql", Absinthe.Plug.GraphiQL, schema: Bloodbath.Schema
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BloodbathWeb.Telemetry
    end
  end
end
