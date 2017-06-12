defmodule Server.Components.Chats do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def register_user(user) do
    GenServer.call(__MODULE__, {:register_user, user})
  end

  def deregister_user(user) do
    GenServer.call(__MODULE__, {:deregister_user, user})
  end

  def list_users do
    GenServer.call(__MODULE__, :list_users)
  end

  def init(_) do
    # TODO: create User and ChatHistory models
    chats = %{}
    {:ok, chats}
  end

  def handle_call({:register_user, user}, _from, chats) do
    case Map.has_key?(chats, user) do
      true -> {:reply, {:error, :already_taken}, chats}
      false -> {:reply, :ok, Map.put(chats, user, %{})}
    end
  end

  def handle_call({:deregister_user, user}, _from, chats) do
    case Map.has_key?(chats, user) do
      true -> {:reply, :ok, Map.delete(chats, user)}
      false -> {:reply, {:error, :already_unregistered}, chats}
    end
  end

  def handle_call(:list_users, _from, chats) do
    {:reply, {:ok, Map.keys chats}, chats}
  end
end
