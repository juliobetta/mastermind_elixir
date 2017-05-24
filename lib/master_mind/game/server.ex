defmodule MasterMind.Game.Server do
  @moduledoc """
  Game Server
  """
  use GenServer

  alias MasterMind.Game.Struct, as: Game

  require Logger
  import MasterMind.Utils.DateTime, only: [now: 0]
  import Enum, only: [shuffle: 1]


  ##############################################################################
  # API ########################################################################
  ##############################################################################

  @doc """
  Returns the game state
  """
  def get_data(id), do: try_call(id, :get_data)


  def check_answer(id, answer), do: try_call(id, {:check_answer, answer})


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

  def handle_call({:check_answer, answer}, _from, game) do
    Logger.debug "Handling :check_answer Game #{game.id}"

    response = case game |> add_answer(answer) do
      {:ok, game} -> {:ok, game |> check_secret(answer)}
      error -> error
    end

    {:reply, response, game}
  end


  ##############################################################################
  # PRIVATE FUNCTIONS ##########################################################
  ##############################################################################

  defp add_answer(game, answer) do
    case Game.get_matches(game.secret, answer) do
      {:ok, matches} ->
        {:ok, %{game | answers: [[answer, shuffle(matches)] | game.answers]}}
      error -> error
    end
  end


  defp check_secret(game, answer) do
    cond do
      game.secret == answer ->
        %{
          game |
          over: true,
          elapsed_time: now() - game.started_at
        }
      true ->
        game
    end
  end


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
