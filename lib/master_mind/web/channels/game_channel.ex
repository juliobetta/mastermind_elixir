defmodule MasterMind.Web.GameChannel do
  @moduledoc """
  Game channel
  """
  require Logger

  use Phoenix.Channel
  alias MasterMind.Game.Server, as: GameServer
  alias MasterMind.Game.Supervisor, as: GameSupervisor
  alias MasterMind.Web.Endpoint, as: GameEndpoint

  def join("game:" <> game_id, _message, socket) do
    Logger.debug "Joining Game channel #{game_id}", game_id: game_id

    player_id = socket.assigns.player_id

    case GameServer.join(game_id, player_id, socket.channel_pid) do
      {:ok, pid} ->
        Process.monitor(pid)

        {:ok, assign(socket, :game_id, game_id)}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end


  def handle_in("game:joined", _message, socket) do
    Logger.debug "Broadcasting player joined #{socket.assigns.game_id}"

    player_id = socket.assigns.player_id

    broadcast! socket, "game:player_added", %{player_id: player_id}
    {:noreply, socket}
  end

  def handle_in("game:get_data", _message, socket) do
    game_id = socket.assigns.game_id
    data = GameServer.get_data(game_id)

    {:reply, {:ok, %{game: data}}, socket}
  end


  def handle_in("game:play", %{"answer" => answer}, socket) do
    Logger.debug "Handling play on GameChannel #{socket.assigns.game_id}"

    game_id = socket.assigns.game_id

    case GameServer.play(game_id, answer) do
      {:ok, %{over: true} = game} ->
        broadcast(socket, "game:over", %{game: game})
        {:noreply, socket}
      {:ok, game} ->
        {:reply, {:ok, game}, socket}
      _ ->
        {:error, {:error, %{reason: "Something went wrong while playing"}}, socket}
    end
  end


  def terminate(reason, socket) do
    Logger.debug "Terminating GameChannel #{socket.assigns.game_id} #{inspect reason}"

    game_id = socket.assigns.game_id
    player_id = socket.assigns.player_id

    case GameServer.player_left(game_id, player_id) do
      {:ok, game} ->
        GameSupervisor.stop_game(game_id)

        broadcast(socket, "game:over", %{game: game})
        broadcast(socket, "game:player_left", %{player_id: player_id})

        :ok
      _ ->
        :ok
    end
  end


  def handle_info(_, socket), do: {:noreply, socket}


  def broadcast_stop(game_id) do
    Logger.debug "Broadcasting game:stopped from GameChannel #{game_id}"

    GameEndpoint.broadcast("game:#{game_id}", "game:stopped", %{})
  end
end
