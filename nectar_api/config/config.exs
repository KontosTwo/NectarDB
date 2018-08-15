# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :nectar_api,
  namespace: NectarAPI,
  ecto_repos: []

# Configures the endpoint
config :nectar_api, NectarAPIWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "w6ypHB+ZGk6mVDs8IK5ZS8bd0BVuzGhzlVP/ba20pkZacqPjKW8evrijWqn/A//r",
  render_errors: [view: NectarAPIWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NectarAPI.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
