defmodule Server.Components.P2P do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def request_socket(username, filename) do
    GenServer.call(__MODULE__, {:request_socket, username, filename})
  end

  def init(_) do
    requests = %{}
    {:ok, requests}
  end

  def handle_call({:request_socket, username, filename}, from, requests) do
    {:noreply, Map.put(requests, {username, filename}, from)}
  end

  def handle_info({:receive_socket, username, filename, socket_pair}, requests) do
    case Map.get(requests, {username, filename}) do
      nil ->
        Logger.error("Received socket pair for {#{username}, #{filename}} without request")
        {:noreply, requests}
      requester ->
        GenServer.reply(requester, {:ok, socket_pair})
        {:noreply, Map.delete(requests, {username, filename})}
    end
  end
end
