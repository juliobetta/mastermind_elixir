defmodule MasterMind.Web.PlayerSocketTest do
  use MasterMind.Web.ChannelCase, async: true

  alias MasterMind.Web.{PlayerSocket}

  @id MasterMind.Application.generate_player_id

  setup do
    {:ok, socket} = connect(PlayerSocket, %{"id" => @id})

    {:ok, socket: socket}
  end


  test "assigns player", %{socket: socket} do
    assert socket.assigns.player_id == @id
  end


  test "assigns id", %{socket: socket} do
    assert socket.id == "players_socket:#{@id}"
  end
end
