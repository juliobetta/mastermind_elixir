defmodule MasterMind.GameTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Server, as: GameServer
  alias MasterMind.Game.Struct, as: Game
  import MasterMind.Application, only: [
    generate_game_id: 0,
    generate_player_id: 0
  ]

  @player_id generate_player_id()


  setup do
    id = generate_game_id()

    {:ok, pid} = GameServer.start_link(id)
    {:ok, game} = GameServer.get_data(id)

    {:ok, game: game, pid: pid, id: id}
  end


  test "creating a new game" do
    {:ok, pid} = GameServer.start_link(generate_game_id())

    assert is_pid(pid)
  end


  test ".get_data getting game data", context do
    {:ok, game} = GameServer.get_data(context[:id])

    assert game == %Game{
      id: context[:id],
      player: nil,
      secret: context[:game].secret,
      started_at: context[:game].started_at,
      elapsed_time: 0,
      over: false,
      answers: [],
      difficulty: :easy
    }
  end


  test ".join adds player to game", %{id: id, pid: pid} do
    assert {:ok, _} = GameServer.join(id, @player_id, pid)
    assert {:ok, %{player: @player_id}} = GameServer.get_data(id)
  end

  test ".join keeps stae when player is the same", %{id: id, pid: pid} do
    GameServer.join(id, @player_id, pid)
    assert {:ok, _} = GameServer.join(id, @player_id, pid)
    assert {:ok, %{player: @player_id}} = GameServer.get_data(id)
  end

  test ".join receiving error when try to join again", %{id: id, pid: pid} do
    GameServer.join(id, @player_id, pid)

    assert {:error, "No more players allowed"} =
      GameServer.join(id, generate_player_id(), pid)
  end


  test ".play returning error when game is already over", context do
    answer = context[:game].secret

    {:ok, _ } = GameServer.play(context[:id], answer)
    {:error, message} = GameServer.play(context[:id], answer)

    assert message == "The game is over"
  end

  test ".play setting over true when secret is equals to answer", context do
    answer = context[:game].secret
    {:ok, game} = GameServer.play(context[:id], answer)

    assert game.over == true
  end

  test ".play adding answer and matches to game state", context do
    answer = [0,0,0,0]
    {:ok, game} = GameServer.play(context[:id], answer)

    game_first_answer = List.first(game.answers)

    assert Enum.count(game.answers) > 0
    assert List.first(game_first_answer) == answer
    assert List.last(game_first_answer) == [-1,-1,-1,-1]
  end

  test ".play returning error when answer count is different than secret", context do
    answer = [1,2]
    {:error, message} = GameServer.play(context[:id], answer)

    assert is_binary(message)
  end

  test ".play setting over=true when answer is equals to secret", context do
    answer = context[:game].secret

    {:ok, game} = GameServer.play(context[:id], answer)

    assert game.over == true
  end
end
