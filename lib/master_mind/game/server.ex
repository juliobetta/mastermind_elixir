defmodule MasterMind.Game.Server do
  @moduledoc """
  Game Server
  """
  use GenServer

  alias MasterMind.Game.Struct, as: Game
  alias MasterMind.Game.Event, as: GameEvent

  require Logger
  import MasterMind.Utils.DateTime, only: [now: 0]
  import Enum, only: [shuffle: 1]


  ##############################################################################
  # PUBLIC API #################################################################
  ##############################################################################

  def get_data(id), do: try_call(id, :get_data)

  def join(id, player_id, pid), do: try_call(id, {:join, player_id, pid})

  def play(id, answer), do: try_call(id, {:check_answer, answer})

  def player_left(id, player_id), do: try_call(id, {:player_left, player_id})


  ##############################################################################
  # GenServer API ##############################################################
  ##############################################################################

  def start_link(id) when is_binary(id) do
    GenServer.start_link(__MODULE__, [id: id, difficulty: :easy], name: ref(id))
  end

  def start_link([id: _, difficulty: _] = params) do
    GenServer.start_link(__MODULE__, params, name: ref(params[:id]))
  end


  def init([id: _, difficulty: _] = params) do
    GameEvent.game_created

    # @todo get game from Cache
    game = Game.new(params)
    {:ok, game}
  end


  def handle_call(:get_data, _from, game), do: {:reply, {:ok, game}, game}

  def handle_call({:check_answer, _}, _from, %{over: true} = game) do
    {:reply, {:error, "The game is over"}, game}
  end

  def handle_call({:check_answer, answer}, _from, game) do
    Logger.debug "Handling :check_answer Game #{game.id}"

    case Game.match_answer(game.secret, answer) do
      {:ok, match} ->
        game = game
        |> add_answer(answer, shuffle(match))
        |> check_secret(answer)

        GameEvent.play

        {:reply, {:ok, game}, game}
      error ->
        {:reply, error, game}
    end
  end

  def handle_call({:join, player_id, pid}, _from, game) do
    Logger.debug "Handling :join for #{player_id} in Game #{game.id}"

    cond do
      game.player == player_id ->
        {:reply, {:ok, self()}, game}
      game.player != nil ->
        {:reply, {:error, "No more players allowed"}, game}
      true ->
        Process.flag(:trap_exit, true)
        Process.monitor(pid)

        game = add_player(game, player_id)

        GameEvent.player_added

        {:reply, {:ok, self()}, game}
    end
  end

  def handle_call({:player_left, player_id}, _from, game) do
    Logger.debug "Handling :player_left for #{player_id} in Game #{game.id}"

    game = %{game | over: true}

    {:reply, {:ok, game}, game}
  end


  @doc """
  Handles exit messages from linked game channels and boards processes
  stopping the game process.
  """
  def handle_info({:DOWN, _ref, :process, _pid, _reason}, game) do
    Logger.debug "Handling message in Game #{game.id}"
    # Logger.debug "#{inspect message}"

    GameEvent.game_stopped(game.id)

    {:stop, :normal, game}
  end


  def terminate(_reason, game) do
    Logger.debug "Terminating Game process #{game.id}"

    GameEvent.game_over

    :ok
  end


  ##############################################################################
  # PRIVATE FUNCTIONS ##########################################################
  ##############################################################################

  defp add_player(%{player: nil} = game, player_id) do
    %{game | player: player_id}
  end


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
