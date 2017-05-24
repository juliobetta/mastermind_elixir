# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :master_mind, MasterMind.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "+281pFyymtokCxxGSl+bwar+1yyt9gBLqvgf7fTW3PcxsBEMBSBot6g9L4odlr9z",
  render_errors: [view: MasterMind.Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MasterMind.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Game opts
config :master_mind,
  params: [
    easy: [
      pegs: 4,
      duplicate: true,
      moves: nil,
      time: nil
    ],
    normal: [
      pegs: 4,
      duplicate: false,
      moves: 12,
      minutes: nil
    ],
    hard: [
      pegs: 6,
      duplicate: false,
      moves: 10,
      minutes: nil
    ],
    expert: [
      pegs: 6,
      duplicate: false,
      moves: 10,
      minutes: 10
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
