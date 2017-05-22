defmodule MasterMind.Game.Server do
  @moduledoc """
  Game Server
  """
  use GenServer
  require Logger

  alias MasterMind.Game.Struct, as: Game
  import MasterMind.Utils.DateTime, only: [now: 0]


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

    game = game
    |> add_answer(answer)
    |> check_secret(answer)

    {:reply, game, game}
  end


  ##############################################################################
  # PRIVATE FUNCTIONS ##########################################################
  ##############################################################################

  defp add_answer(game, answer) do
    matches = Game.get_matches(game.secret, answer)
    %{game | answers: [[answer, matches] | game.answers]}
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
