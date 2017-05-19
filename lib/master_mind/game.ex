defmodule MasterMind.Game do
  @moduledoc """
  Game Server
  """
  use GenServer
  require Logger

  defstruct [
    id: nil,
    answer: [],
    max_attempts: 10,
    total_attempts: 0,
    over: false
  ]


  ###
  # API
  ###

  @doc """
  Returns the game state
  """
  def get_data(id), do: try_call(id, :get_data)


  ###
  # GenServer API
  ###

  def init(id) do
    {:ok, %__MODULE__{id: id}}
  end


  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: ref(id))
  end


  def handle_call(:get_data, _from, game), do: {:reply, game, game}


  ###
  # PRIVATE FUNCTIONS
  ###

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
