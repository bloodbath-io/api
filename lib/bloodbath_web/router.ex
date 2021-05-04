defmodule BloodbathWeb.Router do
  use BloodbathWeb, :router

  pipeline :graphql do
    plug CORSPlug
  end

  pipeline :authenticated do
    plug BloodbathWeb.Pipeline.Authenticated
  end

  scope "/" do
    pipe_through :graphql
    pipe_through :authenticated
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
