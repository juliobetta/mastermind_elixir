defmodule MasterMind.Utils.DateTime do
  @moduledoc """
  Game specific date-time utils
  """

  def now, do: DateTime.utc_now |> DateTime.to_unix
end
