defmodule MasterMind.Game.Struct do
  @moduledoc """
  Defines the game structure
  """
  import String, only: [to_atom: 1]
  alias MasterMind.Utils.Color
  alias MasterMind.Utils.DateTime, as: DateTimeUtils

  @easy_total_pegs 4
  @normal_total_pegs 4
  @hard_total_pegs 6

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

      iex> Game.get_matches([1,2,3,4], [1,2])
      {:error, "Total pegs in answer is not equals to secret"}
      iex> Game.get_matches([1,1,1,1], [1,1,1,1])
      {:ok, [1,1,1,1]}
      iex> Game.get_matches([1,1,1,1], [2,3,4,5])
      {:ok, [-1,-1,-1,-1]}
      iex> Game.get_matches([1,2,3,4], [4,3,2,1])
      {:ok, [0,0,0,0]}
      iex> Game.get_matches([1,2,3,4], [1,1,1,1])
      {:ok, [1,-1,-1,-1]}
      iex> Game.get_matches([1,2,2,1], [1,1,1,1])
      {:ok, [1,-1,-1,1]}
      iex> Game.get_matches([1,4,5,2], [1,2,5,4])
      {:ok, [1,0,1,0]}
  """
  def get_matches(secret, answer) when secret == answer, do: {:ok, [1,1,1,1]}

  def get_matches(secret, answer) when length(secret) != length(answer) do
    {:error, "Total pegs in answer is not equals to secret"}
  end

  def get_matches(secret, answer) do
    do_get_matches(secret, answer, secret, [])
  end


  ##############################################################################
  # PRIVATE FUNCTIONS ##########################################################
  ##############################################################################

  defp do_get_matches([], [], _, acc), do: {:ok, acc |> Enum.reverse}

  # Why using --?, one may ask...
  # In the docs, it says:
  #
  #    "The complexity of a -- b is proportional to length(a) * length(b),
  #     meaning that it will be very slow if both a and b are long lists.
  #     In such cases, consider converting each list to a MapSet and using
  #     MapSet.difference/2."
  #
  # In this case, since the size of both secret and answer is small,
  # limited by the game difficulty, there's no need to
  # convert them to MapSet.
  defp do_get_matches([s_head|s_tail], [a_head|a_tail], secret, acc) do
    match = cond do
      s_head == a_head -> 1
      (a_tail -- [a_head] == a_tail) and (secret -- [a_head] != secret) -> 0
      true -> -1
    end

    secret = unless(match == -1, do: secret -- [a_head], else: secret)

    do_get_matches(s_tail, a_tail, secret, [match|acc])
  end


  defp generate_secret(:easy) do
    Color.take @easy_total_pegs, allow_duplicate: false
  end
  defp generate_secret(:normal), do: Color.take @normal_total_pegs
  defp generate_secret(:hard), do: Color.take @hard_total_pegs


  defp parse_difficulty(value) do
    key = if(is_binary(value), do: to_atom(value), else: value)

    case Enum.member?([:hard, :normal, :easy], key) do
      true -> key
      _ -> :easy
    end
  end
end
