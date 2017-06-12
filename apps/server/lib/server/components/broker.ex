defmodule Server.Components.Broker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def put_online(username, peername) do
    GenServer.call(__MODULE__, {:put_online, username, peername})
  end

  def put_offline(username) do
    GenServer.call(__MODULE__, {:put_offline, username})
  end

  def init(_) do
    peers = %{}
    {:ok, peers}
  end

  def handle_call({:put_online, username, peername}, _from, peers) do
    case Map.has_key?(peers, username) do
      true -> {:reply, {:error, :already_online}, peers}
      false -> {:reply, :ok, Map.put(peers, username, peername)}
    end
  end

  def handle_call({:put_offline, username}, _from, peers) do
    case Map.has_key?(peers, username) do
      true -> {:reply, :ok, Map.delete(peers, username)}
      false -> {:reply, {:error, :already_offline}, peers}
    end
  end
end
