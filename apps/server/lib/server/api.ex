defmodule Server.API do
  alias Server.Components.Connections
  alias Server.Components.Broker
  alias Server.Components.Chats
  alias Server.Components.P2P
  alias Server.Response

  @doc ~S"""
  Serves the given `request`.

  ## Examples

    iex> Server.API.call {:register, "dummy_user"}, []
    {:ok, {:register, "dummy_user"}}
  """
  def call({:register, username}, [from_socket: socket]) do
    registration = with {:ok, peername} <- :inet.peername(socket),
                        :ok <- Connections.link(peername, socket),
                        :ok <- Broker.put_online(peername, username),
                        do: Chats.register_user(username)

    case registration do
      :ok -> {:ok, {:register, username}}
      {:error, _} -> {:error, {:register, username, "already taken"}}
    end
  end

  def call(:unregister, [from_socket: socket]) do
    unregistration = with {:ok, peername} <- :inet.peername(socket),
                          {:ok, username} <- Broker.get_username(peername),
                          :ok <- Connections.unlink(peername),
                          :ok <- Broker.put_offline(peername),
                          :ok <- Chats.deregister_user(username),
                          do: {:ok, {:unregister, username}}

    case unregistration do
      {:error, _} -> {:error, {:unregister, "you", "are already unregistered"}}
      result -> result
    end
  end

  def call({:send_message, to_username, message}, [from_socket: socket]) do
    sending = with {:ok, to_peername} <- Broker.get_peername(to_username),
                   {:ok, from_peername} <- :inet.peername(socket),
                   {:ok, from_username} <- Broker.get_username(from_peername),
                   do: Broker.send_message(from_username, to_peername, message)

    case sending do
      :ok -> {:ok, {:send_message, to_username}}
      {:error, _} -> {:error, {:send_message, to_username}}
    end
  end

  def call({:send_file, username, filename, chunks_count}, _) do
    {:ok, message} = Response.message({:receive_file, username, filename, chunks_count})
    connect_peers = with {:ok, to_peername} <- Broker.get_peername(username),
                         :ok <- Connections.send_message(message, to_peername),
                         do: P2P.expect_socket(username, filename)

    case connect_peers do
      {:ok, socket_pair} -> {:ok, {:send_file, socket_pair}}
      {:error, _} -> {:error, :send_file}
    end
  end

  def call({:receive_socket, username, filename, socket_pair}, _) do
    send(P2P, {:receive_socket, username, filename, socket_pair})
    {:ok, :receive_socket}
  end

  def call({:broadcast_message, message}, [from_socket: socket]) do
    broadcast = with {:ok, peername} <- :inet.peername(socket),
                     {:ok, from_username} <- Broker.get_username(peername),
                     do: Broker.broadcast_message(from_username, message)

    case broadcast do
      :ok -> {:ok, :broadcast_message}
      {:error, _} -> {:error, :broadcast_message}
    end
  end

  def call(:list_users, _options) do
    case Chats.list_users do
      {:ok, []} -> {:error, :list_users}
      {:ok, users} -> {:ok, {:list_users, users}}
    end
  end

  def call(_bad_request, _options), do: {:error, :bad_request}
end
