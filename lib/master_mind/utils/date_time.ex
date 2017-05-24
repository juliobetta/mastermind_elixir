defmodule MasterMind.Utils.DateTime do
  @moduledoc """
  Game specific date-time utils
  """

  @doc """
  Get current unix timestamp

  ## Examples

      iex> is_integer(MasterMind.Utils.DateTime.now())
      true
  """
  @spec now() :: integer
  def now, do: DateTime.utc_now |> DateTime.to_unix


  @doc """
  Convert minutes to second

  ## Examples

      iex> MasterMind.Utils.DateTime.minutes_to_second(1)
      60
      iex> MasterMind.Utils.DateTime.minutes_to_second(1.5)
      90
  """
  @spec minutes_to_second(number) :: integer
  def minutes_to_second(value) when is_number(value) do
    round(value * 60)
  end
end
