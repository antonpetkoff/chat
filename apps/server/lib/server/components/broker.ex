defmodule Server.Components.Broker do
  use GenServer
  alias Server.Components.Connections
  alias Server.Response

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def put_online(peername, username) do
    GenServer.call(__MODULE__, {:put_online, peername, username})
  end

  def put_offline(peername) do
    GenServer.call(__MODULE__, {:put_offline, peername})
  end

  def get_username(peername) do
    GenServer.call(__MODULE__, {:get_username, peername})
  end

  def get_peername(username) do
    GenServer.call(__MODULE__, {:get_peername, username})
  end

  def send_message(from_username, to_peername, message) do
    GenServer.call(__MODULE__, {:send_message, from_username, to_peername, message})
  end

  def broadcast_message(from_username, message) do
    GenServer.call(__MODULE__, {:broadcast_message, from_username, message})
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

  def handle_call({:get_username, peername}, _from, peers) do
    case Map.get(peers, peername) do
      nil -> {:reply, {:error, :not_online}, peers}
      username -> {:reply, {:ok, username}, peers}
    end
  end

  def handle_call({:get_peername, username}, _from, peers) do
    case Enum.find(peers, fn {_, user} -> user == username end) do
      nil -> {:reply, {:error, :not_found}, peers}
      {peername, _} -> {:reply, {:ok, peername}, peers}
    end
  end

  def handle_call({:send_message, from_username, to_peername, message}, _from, peers) do
    do_send_message(
      from_username,
      message,
      &Connections.send_message(&1, to_peername),
      peers
    )
  end

  def handle_call({:broadcast_message, from_username, message}, _from, peers) do
    do_send_message(
      from_username,
      message,
      &Connections.broadcast_message(&1),
      peers
    )
  end

  defp do_send_message(from_username, message_body, send_fn, peers)
       when is_function(send_fn) do
    {:ok, message} = Response.message(from_username, message_body)
    case send_fn.(message) do
      :ok -> {:reply, :ok, peers}
      {:error, _} = error -> {:reply, {:error, error}, peers}
    end
  end
end
