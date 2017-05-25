defmodule MasterMind.Game.StructTest do
  use ExUnit.Case, async: true

  alias MasterMind.Game.Struct, as: Game

  doctest Game


  test "creating a game passing id as param" do
    id = "1"
    game = Game.new id: id

    assert game.id == id
  end

  test "generates id if game is created without passing an id" do
    game = Game.new

    refute is_nil(game.id)
  end


  test "creating a game with difficulty :easy by default" do
    game = Game.new
    assert game.difficulty == :easy
  end

  test "creating a game passing difficulty as param" do
    game = Game.new difficulty: :normal

    assert game.difficulty == :normal
  end

  test "invalid atomic difficulty defaults do :easy" do
    game = Game.new difficulty: :invalid

    assert game.difficulty == :easy
  end

  test "invalid difficulty defaults to :easy" do
    game = Game.new difficulty: "invalid"

    assert game.difficulty == :easy
  end

  test "converts valid difficulty from string to atom" do
    game = Game.new difficulty: "easy"

    assert game.difficulty == :easy
  end


  test "games with difficulty :easy has :secret with 4 pegs" do
    game = Game.new

    assert length(game.secret) == 4
  end

  test "games with difficulty :hard has :secret with 6 pegs" do
    game = Game.new difficulty: :hard

    assert length(game.secret) == 6
  end

end
