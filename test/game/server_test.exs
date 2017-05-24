defmodule MasterMind.GameTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Server, as: GameServer
  alias MasterMind.Game.Struct, as: Game
  import MasterMind.Application, only: [generate_game_id: 0]


  setup do
    id = generate_game_id()

    GameServer.start_link(id)
    {:ok, game} = GameServer.get_data(id)

    {:ok, game: game, id: id}
  end


  test "creating a new game" do
    {:ok, pid} = GameServer.start_link(generate_game_id())

    assert is_pid(pid)
  end


  test ".get_data getting game data", context do
    {:ok, game} = GameServer.get_data(context[:id])

    assert game == %Game{
      id: context[:id],
      secret: context[:game].secret,
      started_at: context[:game].started_at,
      elapsed_time: 0,
      over: false,
      answers: [],
      difficulty: :easy
    }
  end


  test ".check_answer setting over true when secret is equals to answer", context do
    answer = context[:game].secret
    GameServer.check_answer(context[:id], answer)
    {:ok, game} = GameServer.get_data(context[:id])

    assert game.over == true
  end

  test ".check_answer adding answer and matches to game state", context do
    answer = [0,0,0,0]
    GameServer.check_answer(context[:id], answer)
    {:ok, game} = GameServer.get_data(context[:id])

    game_first_answer = List.first(game.answers)

    assert Enum.count(game.answers) > 0
    assert List.first(game_first_answer) == answer
    assert List.last(game_first_answer) == [-1,-1,-1,-1]
  end

  test ".check_answer returning error when answer count is different than secret", context do
    answer = [1,2]
    {:error, message} = GameServer.check_answer(context[:id], answer)

    assert is_binary(message)
  end

  test ".check_answer setting over=true when answer is equals to secret", context do
    answer = context[:game].secret

    {:ok, _} = GameServer.check_answer(context[:id], answer)
    {:ok, game} = GameServer.get_data(context[:id])

    assert game.over == true
  end
end
