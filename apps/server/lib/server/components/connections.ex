defmodule Server.Components.Connections do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def link(peername, socket) do
    GenServer.call(__MODULE__, {:link, peername, socket})
  end

  def unlink(peername) do
    GenServer.call(__MODULE__, {:unlink, peername})
  end

  def send_message(message, peername) do
    GenServer.call(__MODULE__, {:send_message, message, peername})
  end

  def init(_) do
    sockets = %{}
    {:ok, sockets}
  end

  def handle_call({:link, peername, socket}, _from, sockets) do
    case Map.has_key?(sockets, peername) do
      true -> {:reply, {:error, :already_linked}, sockets}
      false -> {:reply, :ok, Map.put(sockets, peername, socket)}
    end
  end

  def handle_call({:unlink, peername}, _from, sockets) do
    case Map.has_key?(sockets, peername) do
      true -> {:reply, :ok, Map.delete(sockets, peername)}
      false -> {:reply, {:error, :already_unlinked}, sockets}
    end
  end

  def handle_call({:send_message, message, peername}, _from, sockets) do
    case Map.get(sockets, peername) do
      nil -> {:reply, {:error, :not_found}, sockets}
      socket -> case :gen_tcp.send(socket, message) do
        :ok -> {:reply, :ok, sockets}
        {:error, _} = error -> {:reply, error, sockets}
      end
    end
  end
end
