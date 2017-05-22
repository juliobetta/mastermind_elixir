defmodule MasterMind.GameTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Server, as: GameServer


  test "creating a new game" do
    {:ok, pid} = GameServer.start_link("1")

    assert is_pid(pid)
  end


  test ".get_data gets the game state" do
    id = "1"

    GameServer.start_link(id)
    game = GameServer.get_data(id)

    assert game.id == id
  end

  @tag :pending
  test ".check_answer checks if answer matches the secret" do
    id = "1"
    GameServer.start_link(id)
    game = GameServer.get_data(id)
    GameServer.check_answer(id, game.secret)

    IO.inspect(GameServer.get_data(id))
  end
end
