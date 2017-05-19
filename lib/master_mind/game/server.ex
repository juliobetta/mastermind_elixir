defmodule MasterMind.Game.Server do
  @moduledoc """
  Game Server
  """
  use GenServer

  alias MasterMind.Game.State


  ###
  # GenServer API
  ###

  def start_link(id) do
    GenServer.start_link(__MODULE__, id)
  end

  def init(id) do
    {:ok, %State{}}
  end
end
