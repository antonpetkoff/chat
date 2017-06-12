defmodule Server.Components.Broker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def put_online(user, socket) do
    GenServer.call(__MODULE__, {:put_online, user, socket})
  end

  def put_offline(user) do
    GenServer.call(__MODULE__, {:put_offline, user})
  end

  def init(_) do
    sockets = %{}
    {:ok, sockets}
  end

  def handle_call({:put_online, user, socket}, _from, sockets) do
    case Map.has_key?(sockets, user) do
      true -> {:reply, {:error, :already_online}, sockets}
      false -> {:reply, :ok, Map.put(sockets, user, socket)}
    end
  end

  def handle_call({:put_offline, user}, _from, sockets) do
    case Map.has_key?(sockets, user) do
      true -> {:reply, :ok, Map.delete(sockets, user)}
      false -> {:reply, {:error, :already_offline}, sockets}
    end
  end
end
