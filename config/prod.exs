use Mix.Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :bloodbath, BloodbathWeb.Endpoint,
  url: [scheme: "http", host: "api.bloodbath.io", port: 80],
  http: [port: {:system, "PORT"}]#,
  # force_ssl: [rewrite_on: [:x_forwarded_proto]]

config :logger, :console,
  format: "[$level] $message\n"

config :sentry,
  dsn: "https://2f59427d96ee470fb5b2eb1401c0f148@o267044.ingest.sentry.io/5767189",
  environment_name: :prod,
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{
    env: "production"
  },
  included_environments: [:prod]

# config :bloodbath, BloodbathWeb.Endpoint#,
      #  force_ssl: [hsts: true]

import_config "prod.secret.exs"
