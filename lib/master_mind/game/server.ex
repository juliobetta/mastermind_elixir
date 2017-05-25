defmodule MasterMind.Game.Server do
  @moduledoc """
  Game Server
  """
  use GenServer
  require Logger

  alias MasterMind.Game.Struct, as: Game


  ##############################################################################
  # API ########################################################################
  ##############################################################################

  @doc """
  Returns the game state
  """
  def get_data(id), do: try_call(id, :get_data)



  ##############################################################################
  # GenServer API ##############################################################
  ##############################################################################

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: ref(id))
  end


  def init(id) do
    # @todo get game from Cache
    game = Game.new(id: id)
    {:ok, game}
  end


  def handle_call(:get_data, _from, game), do: {:reply, game, game}



  ##############################################################################
  # PRIVATE FUNCTIONS ##########################################################
  ##############################################################################

  # Generates global reference
  defp ref(id), do: {:global, {:game, id}}


  defp try_call(id, message) do
    case GenServer.whereis(ref(id)) do
      nil ->
        {:error, "Game does not exist"}
      game ->
        GenServer.call(game, message)
    end
  end
end
