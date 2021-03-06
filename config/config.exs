# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :app,
  ecto_repos: [App.Repo]

# Configures the endpoint
config :app, AppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "qipl+HM73tT8jIbyIxiTAgx/oLt3RfaDuk1gS2LIiQSUsG85a5ZLwVjVeM/TzJxm",
  render_errors: [view: AppWeb.ErrorView, accepts: ~w(html json)],
  # pubsub: [name: App.PubSub, adapter: Phoenix.PubSub.PG2],
  pubsub_server: App.PubSub,
  live_view: [signing_salt: "h/iubDHdvadAtvhdmhiWjWMQl8tuHmha"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :app, :pow,
  user: App.User,
  repo: App.Repo,
  web_module: AppWeb,
  extensions: [PowResetPassword, PowEmailConfirmation, PowInvitation, PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  mailer_backend: MyAppWeb.Pow.Mailer

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine,
  slimleex: PhoenixSlime.LiveViewEngine # If you want to use LiveView

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
