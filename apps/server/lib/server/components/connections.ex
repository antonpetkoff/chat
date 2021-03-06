defmodule Server.Components.Connections do
  @moduledoc """
  Manages a set of peer connections. Each connection is represented by
  a peername key and the peername's socket as value.
  Peer connections can be added with `link` and removed with `unlink`.

  This module can send/broadcast TCP messages to the linked peers.
  A peer connection must be linked before you can send/broadcast message to it.
  """

  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Adds a peer connection with key `peername` and value `socket`.
  After this call succeeds, messages can be sent to this peer.
  """
  def link(peername, socket) do
    GenServer.call(__MODULE__, {:link, peername, socket})
  end

  def unlink(peername) do
    GenServer.call(__MODULE__, {:unlink, peername})
  end

  def send_message(message, peername) do
    GenServer.call(__MODULE__, {:send_message, message, peername})
  end

  def broadcast_message(message, from_peername) do
    GenServer.call(__MODULE__, {:broadcast_message, message, from_peername})
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

  def handle_call({:broadcast_message, message, from_peername}, _from, sockets) do
    case sockets
    |> Enum.reject(&match?({^from_peername, _}, &1))
    |> Enum.map(fn {_, socket} ->
      Task.async(fn -> :gen_tcp.send(socket, message) end)
    end)
    |> Enum.map(&Task.await/1)
    |> Enum.find(&match?({:error, _}, &1)) do
      nil -> {:reply, :ok, sockets}
      {:error, _} = error -> {:reply, error, sockets}
    end
  end
end
