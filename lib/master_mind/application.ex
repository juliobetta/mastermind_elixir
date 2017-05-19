defmodule MasterMind.Application do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(MasterMind.Web.Endpoint, []),
      supervisor(MasterMind.Game.Supervisor, [])

      # worker(MasterMind.Game.Server, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MasterMind.Supervisor]
    Supervisor.start_link(children, opts)
  end


  @doc """
  Generates unique id for games
  """
  def generate_game_id, do: UUID.uuid4()
end
