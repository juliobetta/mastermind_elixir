defmodule MasterMind.Web.GameChannelTest do
  @moduledoc false
  use MasterMind.Web.ChannelCase, async: true
  alias MasterMind.Game.Supervisor, as: GameSupervisor
  alias MasterMind.Game.Server, as: GameServer
  alias MasterMind.Web.{PlayerSocket, GameChannel}
  import MasterMind.Application, only: [
    generate_game_id: 0,
    generate_player_id: 0
  ]

  @player_id generate_player_id()

  setup do
    game_id = generate_game_id()

    {:ok, game} = GameSupervisor.create_game(game_id)
    {:ok, socket} = connect(PlayerSocket, %{"id" => @player_id})
    {:ok, _, game_socket} = subscribe_and_join(
      socket, GameChannel, "game:" <> game_id
    )

    {:ok, game_id: game_id, game: game, socket: socket, game_socket: game_socket}
  end

  test "joining an invalid game channel", %{socket: socket} do
    assert {:error, %{reason: "Game does not exist"}} =
      subscribe_and_join(socket, GameChannel, "game:invalid")
  end


  test("game:get_data fetching the game data",
    %{game_socket: socket, game_socket: socket, game_id: game_id }
  ) do
    {:ok, game} = GameServer.get_data(game_id)

    ref = push(socket, "game:get_data", %{})
    leave(socket)

    assert_reply(ref, :ok, %{game: {:ok, ^game}})
  end


  test("game:joined player joining the game",
    %{game_socket: socket}
  ) do
    push(socket, "game:joined", %{})

    assert_broadcast("game:player_added", %{player_id: @player_id})
  end


  test("game:play receiving an :ok reply",
    %{game_socket: socket, game_id: game_id}
  ) do
    ref = push(socket, "game:play", %{"answer" => [1,2,3,4]})
    leave(socket)

    assert_reply(ref, :ok, %{id: ^game_id})
  end

  test("game:play receiving :error",
    %{game_socket: socket}
  ) do
    ref = push(socket, "game:play", %{"answer" => []})
    leave(socket)

    assert_reply(ref, :error, _)
  end

  test("game:play dispatches game:over when answer is correct",
    %{game_socket: socket, game_id: game_id}
  ) do

    {:ok, game} = GameServer.get_data(game_id)

    push(socket, "game:play", %{"answer": game.secret})
    leave(socket)

    assert_broadcast("game:over", _)
    assert_broadcast("game:player_left", _)
  end


  test("leaving the game channel kills the game",
    %{game_id: game_id, game: game, game_socket: socket}
  ) do
    game_ref = Process.monitor(game)

    Process.unlink(socket.channel_pid)

    ref = leave(socket)
    assert_reply ref, :ok

    assert_receive {:DOWN, ^game_ref, :process, ^game, _}

    assert {:error, "Game does not exist"} =
      GameServer.join(game_id, @player_id, socket.channel_pid)
  end
end
