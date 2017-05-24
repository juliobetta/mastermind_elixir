defmodule MasterMind.Game.Supervisor do
  @moduledoc """
  Game Supervisor
  """

  require Logger

  use Supervisor
  alias MasterMind.Game.Server, as: GameServer


  def start_link, do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)


  def init(_) do
    children = [
      worker(GameServer, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end


  @doc """
  Creates a new supervised game process
  """
  def create_game(id), do: Supervisor.start_child(__MODULE__, [id])


  @doc """
  Returns a list of current games
  """
  def current_games do
    __MODULE__
    |> Supervisor.which_children
    |> Enum.map(&game_data/1)
  end


  @doc """
  Stops the game
  """
  def stop_game(id) do
    Logger.debug "Stopping game #{id} in supervisor"

    pid = GenServer.whereis({:global, {:game, id}})

    Supervisor.terminate_child(__MODULE__, pid)
  end


  # Gets game's state
  defp game_data({_id, pid, _type, _modules}) do
    GenServer.call(pid, :get_data)
  end

end
