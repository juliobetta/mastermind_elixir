defmodule MasterMind.Game.SupervisorTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Supervisor, as: GameSupervisor
  alias MasterMind.Game.Struct, as: Game


  setup do
    on_exit fn ->
      Enum.each GameSupervisor.current_games, fn(game) ->
        GameSupervisor.stop_game(game.id)
      end
    end
  end


  test ".create_game adds a new supervised game" do
    GameSupervisor.create_game(Game.new)
    GameSupervisor.create_game(Game.new)

    counts = Supervisor.count_children(GameSupervisor)

    assert counts.active == 2
  end

  test ".stop_game stops a game process" do
    game = Game.new

    GameSupervisor.create_game(game)
    GameSupervisor.stop_game(game.id)

    counts = Supervisor.count_children(GameSupervisor)

    assert counts.active == 0
  end

  test ".current_games returns a list of running games" do
    game1 = Game.new
    game2 = Game.new

    GameSupervisor.create_game(game1)
    GameSupervisor.create_game(game2)

    ids = GameSupervisor.current_games |> Enum.map(&(&1.id))

    assert [game1.id, game2.id] == ids
  end
end
