# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :nectar_api,
  namespace: NectarAPI

# Configures the endpoint
config :nectar_api, NectarAPIWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jvGA74JWlWgYdlSG3JGyCvoDSnmfAQICn4HNb3wJSHO/Oc/OCnWxEaZK18JfJOvc",
  render_errors: [view: NectarAPIWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: NectarAPI.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :nectar_api, :ecto_repos, []



# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
