defmodule MasterMind.Utils.ColorTest do
  use ExUnit.Case, async: true

  alias MasterMind.Utils.Color


  test "takes the correact amount of elements" do
    items = Color.take(4)

    assert length(items) == 4
  end
end
