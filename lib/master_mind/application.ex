defmodule MasterMind.Application do
  use Application


  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(MasterMind.Web.Endpoint, []),
      supervisor(MasterMind.Game.Supervisor, []),

      worker(MasterMind.Game.Event, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MasterMind.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MasterMind.Web.Endpoint.config_change(changed, removed)
    :ok
  end


  def generate_game_id, do: UUID.uuid4
  def generate_player_id, do: UUID.uuid4
end
