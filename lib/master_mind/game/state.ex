defmodule MasterMind.Game.State do
  @moduledoc """
  Game State
  """
  defstruct [
    id: nil,
    answer: []
  ]

  def new(description) do
    %__MODULE__{
      id: UUID.uuid4(),
      answer: generate_answer()
    }
  end

  defp generate_answer do
    []
  end
end
