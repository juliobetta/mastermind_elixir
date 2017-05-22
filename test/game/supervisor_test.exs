defmodule MasterMind.Game.SupervisorTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Supervisor, as: GameSupervisor


  setup do
    on_exit fn ->
      Enum.each GameSupervisor.current_games, fn(game) ->
        GameSupervisor.stop_game(game.id)
      end
    end
  end


  test ".create_game adds a new supervised game" do
    GameSupervisor.create_game("1")
    GameSupervisor.create_game("2")

    counts = Supervisor.count_children(GameSupervisor)

    assert counts.active == 2
  end


  test "creating games with same ids will not increment children" do
    GameSupervisor.create_game("1")
    GameSupervisor.create_game("1")

    counts = Supervisor.count_children(GameSupervisor)

    assert counts.active == 1
  end


  test ".stop_game stops a game process" do
    id = "1"

    GameSupervisor.create_game(id)
    GameSupervisor.stop_game(id)

    counts = Supervisor.count_children(GameSupervisor)

    assert counts.active == 0
  end


  test ".current_games returns a list of running games" do
    GameSupervisor.create_game("1")
    GameSupervisor.create_game("2")

    ids = GameSupervisor.current_games |> Enum.map(&(&1.id)) |> Enum.sort

    assert ~w(1 2) == ids
  end
end
