defmodule MasterMind.Web.LobbyChannelTest do
  @moduledoc false
  use MasterMind.Web.ChannelCase, async: true
  alias MasterMind.Web.{PlayerSocket, LobbyChannel}
  import MasterMind.Application, only: [generate_player_id: 0]

  @player_id generate_player_id()

  setup do
    {:ok, socket} = connect(PlayerSocket, %{"id" => @player_id})

    {:ok, _, lobby_socket} = subscribe_and_join(
      socket, LobbyChannel, "lobby"
    )

    on_exit fn ->
      close socket
      leave lobby_socket
    end

    {:ok, socket: socket, lobby_socket: lobby_socket}
  end

  test ":join", %{socket: socket} do
    assert {:ok, %{}, _} =
      subscribe_and_join(socket, LobbyChannel, "lobby")
  end


  test ":current_game show current games", %{lobby_socket: socket} do
    ref = push(socket, "current_games", %{})

    assert_reply(ref, :ok, %{games: _})
  end

  test ":new_game creates new game", %{lobby_socket: socket} do
    ref = push(socket, "new_game", %{})

    assert_reply(ref, :ok, %{game_id: _})
  end
end
