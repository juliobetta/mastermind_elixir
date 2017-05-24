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
  # PUBLIC API #################################################################
  ##############################################################################

  @doc """
  Returns the game state
  """
  def get_data(id), do: try_call(id, :get_data)


  def check_answer(id, answer), do: try_call(id, {:check_answer, answer})


  ##############################################################################
  # GenServer API ##############################################################
  ##############################################################################

  def start_link(id) when is_binary(id) do
    GenServer.start_link(__MODULE__, [id: id, difficulty: :easy], name: ref(id))
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: ref(state[:id]))
  end


  def init([id: _, difficulty: _] = state) do
    # @todo get game from Cache
    game = Game.new(state)
    {:ok, game}
  end


  def handle_call(:get_data, _from, game), do: {:reply, {:ok, game}, game}

  def handle_call({:check_answer, answer}, _from, game) do
    Logger.debug "Handling :check_answer Game #{game.id}"

    case Game.match_answer(game.secret, answer) do
      {:ok, match} ->
        match = shuffle(match)
        game = game |> add_answer(answer, match) |> check_secret(answer)
        {:reply, {:ok, match}, game}
      error ->
        {:reply, error, game}
    end
  end


  ##############################################################################
  # PRIVATE FUNCTIONS ##########################################################
  ##############################################################################


  defp add_answer(game, answer, match) do
    %{game | answers: [[answer, match] | game.answers]}
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
