defmodule Server.Components.Broker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def put_online(peername, username) do
    GenServer.call(__MODULE__, {:put_online, peername, username})
  end

  def put_offline(peername) do
    GenServer.call(__MODULE__, {:put_offline, peername})
  end

  def init(_) do
    peers = %{}
    {:ok, peers}
  end

  def handle_call({:put_online, peername, username}, _from, peers) do
    case Map.has_key?(peers, peername) do
      true -> {:reply, {:error, :already_online}, peers}
      false -> {:reply, :ok, Map.put(peers, peername, username)}
    end
  end

  def handle_call({:put_offline, peername}, _from, peers) do
    case Map.has_key?(peers, peername) do
      true -> {:reply, :ok, Map.delete(peers, peername)}
      false -> {:reply, {:error, :already_offline}, peers}
    end
  end
end
