defmodule MasterMind.Utils.Peg do
  @moduledoc """
  Pin Pegs
  """

  @doc """
  Take random pegs from a range of values

  ## Parameters
  - `total` - The amount of pegs
  - `opts`  - Optional params. `allow_duplicate: false` indicates that
  duplicates numbers are not allowed

  ## Examples

      iex> length(MasterMind.Utils.Peg.take(4)) == 4
      true
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
