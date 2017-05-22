defmodule MasterMind.Game.Struct do
  @moduledoc """
  Defines the game structure
  """
  import String, only: [to_atom: 1]
  alias MasterMind.Utils.Color
  alias MasterMind.Utils.DateTime, as: DateTimeUtils


  defstruct [
    id: nil,
    secret: [],
    started_at: nil,
    elapsed_time: 0,
    answers: [],
    difficulty: :easy,
    over: false
  ]


  ##############################################################################
  # PUBLIC FUNCTIONS ###########################################################
  ##############################################################################

  def new(params \\ []) do
    opts = struct(__MODULE__, params)
    difficulty = parse_difficulty(opts.difficulty)

    %__MODULE__{ opts |
      id: if(is_nil(opts.id), do: UUID.uuid4, else: opts.id),
      difficulty: difficulty,
      secret: generate_secret(difficulty),
      started_at: DateTimeUtils.now
    }
  end


  @doc """
  Get matches from a secret. The possibles values are:

  - `1` for color and position
  - `0` for color
  - `-1` when color nor position are matched

  ## Parameters
  - `secret` - List, The game secret
  - `answer` - List, The user guess

  ## Examples

      Game.get_matches
  """
  def get_matches(secret, answer) do
    do_get_matches(secret, answer, secret, []) |> Enum.reverse
  end

  defp do_get_matches([], [], _, acc), do: acc

  # `sh` - Secret head
  # `st` - Secret tail
  # `ah` - Answer head
  # `at` - Answer tail
  defp do_get_matches([sh|st], [ah|at], secret, acc) do
    match = cond do
      sh == ah -> 1
      Enum.member?(secret, ah) -> 0
      true -> -1
    end

    do_get_matches(st, at, secret, [match|acc])
  end


  ##############################################################################
  # PRIVATE FUNCTIONS ##########################################################
  ##############################################################################

  defp generate_secret(:easy),   do: Color.take 4, allow_duplicate: false
  defp generate_secret(:normal), do: Color.take 4
  defp generate_secret(:hard),   do: Color.take 6
  defp generate_secret(_),       do: generate_secret(:easy)


  defp parse_difficulty(value) do
    key = if(is_binary(value), do: to_atom(value), else: value)

    case Enum.member?([:hard, :normal, :easy], key) do
      true -> key
      _ -> :easy
    end
  end
end
