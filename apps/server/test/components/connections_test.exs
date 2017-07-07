defmodule Server.ConnectionsTest do
  use ExUnit.Case, async: true
  alias Server.Components.Connections

  setup do
    {:ok, _pid} = Connections.start_link
    peername = {"localhost", 4252}
    socket = %{:dummy => :socket}
    {:ok, %{peername: peername, socket: socket}}
  end

  test "it links a new connection", %{peername: peername, socket: socket} do
    assert :ok == Connections.link(peername, socket)
  end

  test "it unlinks a linked connection", %{peername: peername, socket: socket} do
    assert :ok == Connections.link(peername, socket)
    assert {:error, :already_linked} == Connections.link(peername, socket)
  end

  test "it doesn't link an already linked connection", %{peername: peername, socket: socket} do
    assert :ok == Connections.link(peername, socket)
    assert {:error, :already_linked} == Connections.link(peername, socket)
  end

  test "it doesn't unlink an already unlinked connection", %{peername: peername, socket: socket} do
    assert :ok == Connections.link(peername, socket)
    assert :ok == Connections.unlink(peername)
    assert {:error, :already_unlinked} == Connections.unlink(peername)
  end

  test "it can't unlink an unexisting connection", %{peername: peername} do
    assert {:error, :already_unlinked} == Connections.unlink(peername)
  end
end
