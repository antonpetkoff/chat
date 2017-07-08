defmodule Server.Components.P2P do
  @moduledoc """
  A helper module for implementing peer-to-peer file transfer between clients.
  When a file is sent from the sender client, the server asks the receiver
  client to open a new socket and give the socket pair to the server.
  This socket pair is given to the sender client and the server leaves the
  two clients to transfer the file themselves.
  """

  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns a socket pair from a client registered with `username`
  in order to send file with file name `filename`.
  """
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
