# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :fungus_toast,
  ecto_repos: [FungusToast.Repo]

# Configures the endpoint
config :fungus_toast, FungusToastWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "58xHsz2L9zlkku0BPWOb5QjBwwM4d02O3zxw6Lg5F9hfrVkQWe9CXmlMlalcrt6A",
  render_errors: [view: FungusToastWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FungusToast.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
