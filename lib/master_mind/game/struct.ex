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

      iex> Game.get_matches([1,2,3,4], [1,2])
      {:error, "Total elements of answer is not equals to secret"}
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
  def get_matches(secret, answer) do
    cond do
      Enum.count(secret) != Enum.count(answer) ->
        {:error, "Total elements of answer is not equals to secret"}
      true ->
        do_get_matches(secret, answer, secret, [])
    end

  end

  def get_matches(secret, answer) when secret == answer, do: {:ok, [1,1,1,1]}

  defp do_get_matches([], [], _, acc), do: {:ok, acc |> Enum.reverse}

  defp do_get_matches([s_head|s_tail], [a_head|a_tail], secret, acc) do
    match = cond do
      s_head == a_head -> 1
      (a_tail -- [a_head] == a_tail) and (secret -- [a_head] != secret) -> 0
      true -> -1
    end

    secret = unless(match == -1, do: secret -- [a_head], else: secret)

    do_get_matches(s_tail, a_tail, secret, [match|acc])
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
