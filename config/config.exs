# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :alice_in_goals,
  ecto_repos: [AliceInGoals.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :alice_in_goals, AliceInGoalsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AliceInGoalsWeb.ErrorHTML, json: AliceInGoalsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AliceInGoals.PubSub,
  live_view: [signing_salt: "qCbLa/0k"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.2",
  alice_in_goals: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.7",
  alice_in_goals: [
    args: ~w(
      --input=css/app.css
      --output=../priv/static/assets/css/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n"

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Ueberauth for OAuth
config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, []}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
