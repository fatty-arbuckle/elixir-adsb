# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :aircraft_viewer,
  namespace: AircraftViewer

# Configures the endpoint
config :aircraft_viewer, AircraftViewerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tKGZzusaGRG6TLA5U2k87bnw+p8yxM8Zvh/wLCbtN8ss5zDV36z91iDzGeO2ppw3",
  render_errors: [view: AircraftViewerWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: AircraftViewer.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
