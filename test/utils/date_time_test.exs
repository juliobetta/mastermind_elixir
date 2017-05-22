defmodule MasterMind.Utils.DateTimeTest do
  use ExUnit.Case, async: true

  alias MasterMind.Utils.DateTime, as: DateTimeUtils


  test ".now returns the current unix timestamp" do
    assert is_integer(DateTimeUtils.now)
  end
end
