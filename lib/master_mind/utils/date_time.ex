defmodule MasterMind.Utils.DateTime do
  @moduledoc """
  Game specific date-time utils
  """

  @spec now() :: integer
  def now, do: DateTime.utc_now |> DateTime.to_unix
end
