defmodule Server.API do
  alias Server.Components.Connections
  alias Server.Components.Broker
  alias Server.Components.Chats

  @doc ~S"""
  Serves the given `request`.

  ## Examples

    iex> Server.API.call {:register, "dummy_user"}, []
    {:ok, {:register, "dummy_user"}}
  """
  def call({:register, username}, [from_socket: socket]) do
    peername = :inet.peername socket

    registration = with :ok <- Connections.link(peername, socket),
                        :ok <- Broker.put_online(peername, username),
                        do: Chats.register_user(username)

    case registration do
      :ok -> {:ok, {:register, username}}
      {:error, _} -> {:error, {:register, username, "already taken"}}
    end
  end

  def call(:list_users, _options) do
    {:ok, users} = Chats.list_users
    {:ok, {:list_users, users}}
  end

  def call(_bad_request, _options), do: {:error, :bad_request}
end
