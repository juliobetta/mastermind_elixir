defmodule MasterMind.Game.Server do
  @moduledoc """
  Game Server
  """
  use GenServer
  require Logger


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

  def start_link(params) do
    GenServer.start_link(__MODULE__, params, name: ref(params.id))
  end


  def init(state) do
    {:ok, state}
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
