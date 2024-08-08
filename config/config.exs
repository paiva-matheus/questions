# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :questions,
  ecto_repos: [Questions.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :questions, QuestionsWeb.Endpoint,
  url: [host: "0.0.0.0"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [view: QuestionsWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Questions.PubSub,
  live_view: [signing_salt: "Ko1n2vjV"],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg|json)$},
      ~r{lib/questions_web/views/.*(ex)$},
      ~r{lib/questions_web/controllers/.*(ex)$}
    ]
  ],
  reloadable_compilers: [:gettext, :phoenix, :elixir, :phoenix_swagger]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :questions, Questions.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Oban config
config :questions, Oban,
  repo: Questions.Repo,
  queues: [default: 10, notifications: 10]

# Guardian config
config :questions, Questions.AccessControl.Guardian,
  issuer: "questions",
  secret_key: System.get_env("GUARDIAN_TOKEN")

config :bcrypt_elixir, log_rounds: 4

# Swagger
config :questions, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: QuestionsWeb.Router,
      endpoint: QuestionsWeb.Endpoint
    ]
  }

config :phoenix_swagger, json_library: Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
