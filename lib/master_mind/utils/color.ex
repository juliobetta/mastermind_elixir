defmodule MasterMind.Utils.Color do
  @moduledoc """
  Pin Colors
  """

  @doc """
  Take random colors from a range of values

  ## Parameters
  - `total` - The amount of colors
  - `opts`  - Optional params. `allow_duplicate: false` indicates that
  duplicates numbers are not allowed

  ## Examples

      colors = Color.take(4)
      [1,3,5,1]
  """
  def take(total, opts \\ [])
  def take(total, []), do: do_take(total, [])
  def take(total, [allow_duplicate: true]), do: do_take(total, [])
  def take(total, [allow_duplicate: false]) do
    1..(total+2) |> Enum.shuffle |> Enum.take(total)
  end

  defp do_take(0, acc), do: acc
  defp do_take(total, acc) do
    range = 1..(total+2)
    [rand] = Enum.take_random(range, 1)
    do_take(total-1, [rand|acc])
  end
end
