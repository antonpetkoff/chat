defmodule Server.BrokerTest do
  use ExUnit.Case, async: true
  alias Server.Components.Broker

  setup do
    {:ok, _pid} = Broker.start_link
    peername = {"localhost", 4252}
    username = "dingo"
    {:ok, %{peername: peername, username: username}}
  end

  test "it puts a user online", %{peername: peername, username: username} do
    assert :ok == Broker.put_online(peername, username)
  end

  test "it puts a user offline", %{peername: peername, username: username} do
    assert :ok == Broker.put_online(peername, username)
    assert :ok == Broker.put_offline(peername)
  end
end
