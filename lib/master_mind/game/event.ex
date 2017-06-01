defmodule MasterMind.Game.Event do
  def start_link do
    {:ok, manager} = GenEvent.start_link(name: __MODULE__)

    handlers = [
      MasterMind.Game.EventHandler
    ]

    Enum.each(handlers, &GenEvent.add_handler(manager, &1, []))

    {:ok, manager}
  end

  def game_created, do: GenEvent.notify(__MODULE__, :game_created)
  def player_added, do: GenEvent.notify(__MODULE__, :player_added)
  def game_over, do: GenEvent.notify(__MODULE__, :game_over)
  def game_stopped(game_id), do: GenEvent.notify(__MODULE__, {:game_stopped, game_id})
  def play, do: GenEvent.notify(__MODULE__, :play)
end
