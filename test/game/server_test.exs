defmodule MasterMind.GameTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Server, as: GameServer
  import MasterMind.Application, only: [generate_game_id: 0]


  setup do
    id = generate_game_id()

    GameServer.start_link(id)
    game = GameServer.get_data(id)

    {:ok, game: game, id: id}
  end


  test "creating a new game" do
    {:ok, pid} = GameServer.start_link(generate_game_id())

    assert is_pid(pid)
  end


  test ".get_data gets game data", context do
    game = GameServer.get_data(context[:id])

    assert game.id == context[:id]
  end


  test ".check_answer set over true when secret is equals to answer", context do
    answer = context[:game].secret
    game = GameServer.check_answer(context[:id], answer)

    assert game.over == true
  end
end
