defmodule MasterMind.Game.Struct do
  @moduledoc """
  Defines the game structure
  """
  import String, only: [to_atom: 1]
  alias MasterMind.Utils.Color


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
      id: UUID.uuid4,
      difficulty: difficulty,
      secret: generate_secret(difficulty),
      started_at: DateTime.utc_now |> DateTime.to_unix
    }
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
