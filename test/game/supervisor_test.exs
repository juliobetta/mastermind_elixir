defmodule MasterMind.Game.SupervisorTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Supervisor, as: GameSupervisor
  import MasterMind.Application, only: [generate_game_id: 0]


  setup do
    on_exit fn ->
      Enum.each GameSupervisor.current_games, fn(game) ->
        GameSupervisor.stop_game(game.id)
      end
    end
  end


  test ".create_game adds a new supervised game" do
    for _ <- 1..2, do: GameSupervisor.create_game(generate_game_id())

    counts = Supervisor.count_children(GameSupervisor)

    assert counts.active == 2
  end


  test "creating games with same ids will not increment children" do
    id = generate_game_id()
    for _ <- 1..2, do: GameSupervisor.create_game(id)

    counts = Supervisor.count_children(GameSupervisor)

    assert counts.active == 1
  end


  test ".stop_game stops a game process" do
    id = generate_game_id()

    GameSupervisor.create_game(id)
    GameSupervisor.stop_game(id)

    counts = Supervisor.count_children(GameSupervisor)

    assert counts.active == 0
  end


  test ".current_games returns a list of running games" do
    [id1, id2] = [generate_game_id(), generate_game_id()]
    GameSupervisor.create_game(id1)
    GameSupervisor.create_game(id2)

    results = GameSupervisor.current_games |> Enum.map(&(&1.id))

    assert Enum.member?(results, id1) and Enum.member?(results, id2)
  end
end
