defmodule Server.Components.P2P do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def expect_socket(username, filename) do
    GenServer.call(__MODULE__, {:expect_socket, username, filename})
  end

  def init(_) do
    expectations = %{}
    {:ok, expectations}
  end

  def handle_call({:expect_socket, username, filename}, from, expectations) do
    {:noreply, Map.put(expectations, {username, filename}, from)}
  end

  def handle_info({:receive_socket, username, filename, socket_pair}, expectations) do
    case Map.get(expectations, {username, filename}) do
      nil ->
        Logger.error("Received socket pair for {#{username}, #{filename}} without request")
        {:noreply, expectations}
      expecter ->
        GenServer.reply(expecter, {:ok, socket_pair})
        {:noreply, Map.delete(expectations, {username, filename})}
    end
  end
end
