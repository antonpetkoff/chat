defmodule Server.ConnectionsTest do
  use ExUnit.Case, async: true
  alias Server.Components.Connections

  setup do
    {:ok, _pid} = Connections.start_link
    :ok
  end

  test "doesn't link an already linked connection" do
    peername = {"localhost", 4252}
    socket = %{:dummy => :socket}
    assert :ok == Connections.link(peername, socket)
    assert {:error, :already_linked} == Connections.link(peername, socket)
  end

  test "doesn't unlink an already unlinked connection" do
    peername = {"localhost", 4252}
    socket = %{:dummy => :socket}
    assert :ok == Connections.link(peername, socket)
    assert :ok == Connections.unlink(peername)
    assert {:error, :already_unlinked} == Connections.unlink(peername)
  end
end
