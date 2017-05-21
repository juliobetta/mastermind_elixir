defmodule MasterMind.GameTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Server, as: GameServer
  alias MasterMind.Game.Struct, as: Game


  test "creating a new game" do
    {:ok, pid} = GameServer.start_link(Game.new)

    assert is_pid(pid)
  end


  test ".get_data gets the game state" do
    game = Game.new

    GameServer.start_link(game)
    data = GameServer.get_data(game.id)

    assert game.id == data.id
  end
end
