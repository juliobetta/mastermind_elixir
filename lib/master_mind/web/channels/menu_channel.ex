defmodule MasterMind.Web.MenuChannel do
  @moduledoc """
  Lobby channel
  """
  require Logger

  use MasterMind.Web, :channel
  alias MasterMind.Web.Endpoint, as: GameEndpoint
  alias MasterMind.Game.Supervisor, as: GameSupervisor
  alias MasterMind.Application, as: GameApp


  def join("menu", _msg, socket) do
    {:ok, socket}
  end


  def handle_in("current_games", _params, socket) do
    {:reply, {:ok, %{games: GameSupervisor.current_games}}, socket}
  end

  def handle_in("new_game", _params, socket) do
    game_id = GameApp.generate_game_id()
    GameSupervisor.create_game(game_id)

    {:reply, {:ok, %{game_id: game_id}}, socket}
  end


  def broadcast_current_games do
    Logger.debug "Broadcasting current games from LobbyChannel"

    GameEndpoint.broadcast("menu", "update_games", %{games: GameSupervisor.current_games})
  end
end
